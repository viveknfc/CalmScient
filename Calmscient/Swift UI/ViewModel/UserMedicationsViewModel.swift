//
//  UserMedicationsViewModel.swift
//  Calmscient
//
//  Medications list state and API parity with legacy `UserMedicationsViewController`.
//
//  Vivek
//  14 May 2026
//

import Foundation
import SwiftUI
import UIKit
import UserNotifications

@available(iOS 16.0, *)
@MainActor
final class UserMedicationsViewModel: ObservableObject, MedicalCalendarHeaderProviding {

    weak var hostViewController: UIViewController?

    /// Presents the same bottom-sheet date picker used elsewhere (`newPickerViewVC`).
    var presentFullDatePickerFromBottom: (() -> Void)?

    var selectedCalendarDate: Date { selectedMedicationDate }

    @Published private(set) var medicationRows: [MedicineDetails] = []
    @Published var selectedTimeSlot: TimeSlot = .morning
    @Published private(set) var selectedMedicationDate: Date = UserMedicationsViewModel.defaultStartOfTodayLocal()
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var showEmptyState: Bool = false

    @Published private(set) var takeAllTitle: String = NSLocalizedString("take_all", comment: "")
    @Published private(set) var takeAllEnabled: Bool = false
    @Published private(set) var takeAllUsesTakenStyle: Bool = false

    let infoBannerText = "Please select the medication you are currently taking.".localized

    private var medicationToDelete: MedicalDetails?

    private static func defaultStartOfTodayLocal() -> Date {
        Calendar.current.startOfDay(for: Date())
    }

    private var anchorView: UIView? { hostViewController?.view }
    private let noRecordsToastKey = "medication_no_records_toast"
    private let medicationRequestTimeoutToastKey = "medication_request_timeout_toast"

    func onHostWillAppear() {
        navigationChromeTitle = "Medications".localized
        tabBarHomeTitle = "main_tab_bar_home".localized
        fetchMedications(for: selectedMedicationDate)
    }

    /// Applied by hosting controller / parent for tab bar parity with legacy screen.
    var navigationChromeTitle: String = ""
    var tabBarHomeTitle: String = ""

    func selectCalendarDate(_ date: Date) {
        selectMedicationDate(date)
    }

    func selectMedicationDate(_ date: Date) {
        medicationRows = []
        selectedMedicationDate = Calendar.current.startOfDay(for: date)
        fetchMedications(for: selectedMedicationDate)
    }

    func selectMedicationDateFromMonthPicker(_ date: Date) {
        selectMedicationDate(date)
    }

    func setTimeSlot(_ slot: TimeSlot) {
        selectedTimeSlot = slot
        refreshTakeAllButtonState()
    }

    func openBackToMedicalRecords() {
        guard let nav = hostViewController?.navigationController else { return }
        nav.pushViewController(UserMedicalRecordsHostingController(), animated: true)
    }

    func openAddMedication() {
        guard let nav = hostViewController?.navigationController else { return }
        let vm = AddEditMedicationViewModel(
            isEditMode: false,
            medicationData: nil,
            refreshControlClosure: { [weak self] _ in
                self?.fetchMedications(for: self?.selectedMedicationDate ?? Date())
            }
        )
        nav.pushViewController(AddUserMedicationsViewController(viewModel: vm), animated: true)
    }

    func openEditMedication(_ row: MedicineDetails) {
        guard let nav = hostViewController?.navigationController else { return }
        let vm = AddEditMedicationViewModel(
            isEditMode: true,
            medicationData: row,
            refreshControlClosure: { [weak self] _ in
                self?.fetchMedications(for: self?.selectedMedicationDate ?? Date())
            }
        )
        let vc = AddUserMedicationsViewController(viewModel: vm)
        vc.title = "Edit medications"
        nav.pushViewController(vc, animated: true)
    }

    func openMedicationDetail(_ row: MedicineDetails) {
        guard let nav = hostViewController?.navigationController else { return }
        let expired = row.medicationDetailsByDate.first?.medicalDetails.expired ?? 0
        guard expired != 1 else { return }
        nav.pushViewController(MedicationsDetailHostingController(medicineDetails: row), animated: true)
    }

    func confirmDeleteMedication(_ row: MedicineDetails) {
        let alert = UIAlertController(
            title: AppHelper.getLocalizeString(str: "Confirm Deletion"),
            message: AppHelper.getLocalizeString(str: "Are you sure you want to delete this medication?"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: AppHelper.getLocalizeString(str: "No"), style: .cancel))
        alert.addAction(UIAlertAction(title: AppHelper.getLocalizeString(str: "Yes"), style: .destructive) { [weak self] _ in
            self?.deleteMedication(row)
        })
        if let cancel = alert.actions.first(where: { $0.title == AppHelper.getLocalizeString(str: "No") }) {
            cancel.setValue(#colorLiteral(red: 0.431, green: 0.420, blue: 0.702, alpha: 1), forKey: "titleTextColor")
        }
        hostViewController?.present(alert, animated: true)
    }

    func toggleTakeAllForCurrentSlot() {
        let status = slotAggregateStatus(for: selectedTimeSlot)
        let newTakenState = !status.allTaken
        var allPmtIds: [String] = []
        var allMedicineTakenID: [Int] = []
        var medicationDateTimes: [String] = []

        for medication in medicationRows {
            guard let medicalDetails = medication.medicationDetailsByDate.first?.medicalDetails else { continue }
            if medicalDetails.expired == 1 { continue }

            for scheduled in medicalDetails.scheduledTimeList {
                for time in scheduled.scheduledTimes {
                    var shouldInclude = false
                    switch selectedTimeSlot {
                    case .morning: shouldInclude = time.medicineTime.isDayTimeAM()
                    case .afternoon: shouldInclude = time.medicineTime.isDayTimePM()
                    case .evening: shouldInclude = time.medicineTime.isDayTimeEvening()
                    }
                    guard shouldInclude else { continue }
                    allPmtIds.append(time.pmtId)
                    allMedicineTakenID.append(time.medicineTakenID ?? 0)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    if let date = dateFormatter.date(from: medication.date) {
                        let outputFormatter = DateFormatter()
                        outputFormatter.dateFormat = "yyyy-MM-dd"
                        let formattedDate = outputFormatter.string(from: date)
                        medicationDateTimes.append("\(formattedDate) \(time.medicineTime)")
                    }
                }
            }
        }

        let medicineTaken = newTakenState ? "1" : "0"
        guard !allPmtIds.isEmpty else { return }
        markMedication(
            pmtIds: allPmtIds,
            medicineTaken: medicineTaken,
            medicationDateTimes: medicationDateTimes,
            medicineTakenIds: allMedicineTakenID
        )
    }

    func toggleDoseTaken(for row: MedicineDetails, timeSlot: TimeSlot) {
        guard let slot = UserMedicationsDosePresentation.build(record: row, timeSlot: timeSlot),
              slot.isInteractive else { return }
        let alarm = slot.alarm
        let medicineTaken = (alarm.medicineTaken == "1") ? "0" : "1"
        let pmtId = alarm.pmtId
        let takenId = alarm.medicineTakenID ?? 0
        let responseTime = alarm.medicineTime

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        guard let medicationDateParsed = dateFormatter.date(from: row.date) else { return }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = outputFormatter.string(from: medicationDateParsed)
        let combined = ["\(formattedDate) \(responseTime)"]

        markMedication(
            pmtIds: [pmtId],
            medicineTaken: medicineTaken,
            medicationDateTimes: combined,
            medicineTakenIds: [takenId]
        )
    }

    func refreshTakeAllButtonState() {
        let status = slotAggregateStatus(for: selectedTimeSlot)
        takeAllUsesTakenStyle = status.allTaken
        takeAllTitle = NSLocalizedString(status.allTaken ? "taken" : "take_all", comment: "")
        takeAllEnabled = status.hasActive
    }

    // MARK: - Private — fetch

    private func fetchMedications(for date: Date) {
        guard let loginResponse = ApplicationSharedInfo.shared.loginResponse else {
            anchorView?.hideToastActivity()
            return
        }

        isLoading = true
        anchorView?.showToastActivity()

        let cal = Calendar.current
        // API expects a two-day window: the calendar day being viewed ("today") and the following day ("tomorrow").
        let fromDay = cal.startOfDay(for: date)
        guard let toDay = cal.date(byAdding: .day, value: 1, to: fromDay) else {
            isLoading = false
            anchorView?.hideToastActivity()
            anchorView?.showToast(message: "An Unknown error occured. Please check with Admin".localized)
            return
        }
        var params: [String: Any] = [:]
        params["patientLocationId"] = loginResponse.patientLocationID
        params["patientId"] = loginResponse.patientID
        params["clientId"] = loginResponse.clientID

        params["fromDate"] = fromDay.dateInMMDDYYYYFormat()
        params["toDate"] = toDay.dateInMMDDYYYYFormat()

        APIService.getMedicationsAPICalling(params: params) { [weak self] (response: MedicationDetailsResponse?, failureResponse: FailureResponse?, error: Error?) in
            Task { @MainActor in
                guard let self else { return }

                if let err = error {
                    self.isLoading = false
                    self.anchorView?.hideToastActivity()
                    if (err as NSError).code == NSURLErrorTimedOut {
                        self.anchorView?.showToast(message: self.medicationRequestTimeoutToastKey.localized)
                    } else {
                        self.anchorView?.showToast(message: err.localizedDescription)
                    }
                    return
                }

                if let response = response {
                    if response.response.responseCode == 200 {
                        self.medicationRows = response.medicineDetails
                            .filter { $0.date == fromDay.dateInMMDDYYYYFormat() }
                            .sorted {
                                ($0.medicationDetailsByDate.first?.medicalDetails.medicationId ?? Int.max) >
                                    ($1.medicationDetailsByDate.first?.medicalDetails.medicationId ?? Int.max)
                            }
                        self.showEmptyState = false
                        self.scheduleAlarmsFromCurrentRows()
                        self.refreshTakeAllButtonState()
                    } else if response.response.responseCode == 400 {
                        self.medicationRows = []
                        self.showEmptyState = true
                    } else {
                        self.medicationRows = []
                        self.showEmptyState = true
                        self.anchorView?.showToast(message: self.localizedMedicationToastMessage(response.response.responseMessage))
                    }
                } else if let failureResponse = failureResponse {
                    self.anchorView?.showToast(message: self.localizedMedicationToastMessage(failureResponse.statusResponse.responseMessage))
                    self.showEmptyState = false
                }

                self.isLoading = false
                self.anchorView?.hideToastActivity()
            }
        }
    }

    private func localizedMedicationToastMessage(_ rawMessage: String) -> String {
        let normalized = rawMessage.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if normalized == "no records" || normalized == "no record" {
            return noRecordsToastKey.localized
        }
        return rawMessage
    }

    // MARK: - Private — mark medication

    private func markMedication(pmtIds: [String], medicineTaken: String, medicationDateTimes: [String], medicineTakenIds: [Int]) {
        let pmtIdInt = pmtIds.compactMap { Int($0) }
        guard let medicineTakenInt = Int(medicineTaken) else { return }

        let params: [String: Any] = [
            "pmtId": pmtIdInt,
            "medicineTaken": medicineTakenInt,
            "medicationdatetime": medicationDateTimes,
            "medicineTakenId": medicineTakenIds,
        ]

        guard let host = hostViewController else { return }

        anchorView?.showToastActivity()
        APIService.MarkMedicationAPICalling(
            host,
            params: params,
            method: "POST",
            accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleMarkMedicationResponse(response)
            }
        }
    }

    private func handleMarkMedicationResponse(_ response: AnyObject) {
        anchorView?.hideToastActivity()

        if let responseDict = response as? [String: Any],
           let responseCode = responseDict["responseCode"] as? Int,
           responseCode == 200 {
            hostViewController?.showSuccessAlert(successContent: responseDict["responseMessage"] as? String, centreImage: nil) { [weak self] in
                self?.fetchMedications(for: self?.selectedMedicationDate ?? Date())
            }
        } else {
            fetchMedications(for: selectedMedicationDate)
        }
    }

    // MARK: - Private — delete

    private func deleteMedication(_ row: MedicineDetails) {
        guard let medicationDetails = row.medicationDetailsByDate.first else { return }
        medicationToDelete = medicationDetails.medicalDetails
        let prescriptionID = medicationDetails.medicalDetails.prescriptionID
        let params: [String: Int] = ["prescriptionID": prescriptionID]

        guard let host = hostViewController else { return }

        anchorView?.showToastActivity()
        APIService.deletMedicationAPICalling(
            host,
            params: params,
            method: "POST",
            accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleDeleteMedicationResponse(response)
            }
        }
    }

    private func handleDeleteMedicationResponse(_ response: AnyObject) {
        anchorView?.hideToastActivity()

        if let responseDict = response as? [String: Any],
           let responseMessage = responseDict["responseMessage"] as? String,
           let responseCode = responseDict["responseCode"] as? Int,
           responseCode == 200 {

            anchorView?.showToast(message: responseMessage)

            if let deletedMedication = medicationToDelete {
                for timeGroup in deletedMedication.scheduledTimeList {
                    for alarmD in timeGroup.scheduledTimes where alarmD.alarmEnabled == "1" {
                        let alarmTime = alarmD.alarmTime
                        let repeatStrings = alarmD.`repeat`
                        let identifier = alarmTime.replacingOccurrences(of: " ", with: "_")
                        let weekdayMap: [String: Int] = [
                            "Sun": 1, "Mon": 2, "Tue": 3, "Wed": 4, "Thu": 5, "Fri": 6, "Sat": 7,
                            "Dom": 1, "Lun": 2, "Mar": 3, "Mié": 4, "Jue": 5, "Vie": 6, "Sáb": 7,
                        ]
                        let repeatDays = repeatStrings.compactMap { weekdayMap[$0] }
                        deleteAlarmNotification(identifier: identifier, repeatDays: repeatDays)
                    }
                }
            }

            fetchMedications(for: selectedMedicationDate)
        }
    }

    // MARK: - Take-all / slot status (parity with `UserMedicationsTableCell` + visible cell scan)

    private func slotAggregateStatus(for timeSlot: TimeSlot) -> (hasActive: Bool, allTaken: Bool) {
        var hasActiveSlot = false
        var allActiveTaken = true

        for record in medicationRows {
            guard let medical = record.medicationDetailsByDate.first?.medicalDetails else { continue }
            if medical.expired == 1 { continue }
            guard let slot = UserMedicationsDosePresentation.build(record: record, timeSlot: timeSlot) else { continue }
            if slot.isInteractive {
                hasActiveSlot = true
                if !slot.isTaken {
                    allActiveTaken = false
                }
            }
        }

        return (hasActiveSlot, hasActiveSlot && allActiveTaken)
    }

    // MARK: - Alarms (copied from legacy controller)

    private func scheduleAlarmsFromCurrentRows() {
        for medication in medicationRows {
            for detail in medication.medicationDetailsByDate {
                let medicalDetails = detail.medicalDetails
                for timeGroup in medicalDetails.scheduledTimeList {
                    for alarm in timeGroup.scheduledTimes where alarm.alarmEnabled == "1" {
                        let alarmTime = alarm.alarmTime
                        let parts = alarmTime.split(separator: " ")
                        guard parts.count == 2 else { continue }
                        let datePart = String(parts[0])
                        let timePart = String(parts[1])
                        let identifier = "\(datePart)_\(timePart)"

                        let timeComponents = timePart.split(separator: ":")
                        guard timeComponents.count >= 2,
                              let hour = Int(timeComponents[0]),
                              let minute = Int(timeComponents[1]) else { continue }

                        let repeatStrings = alarm.`repeat`
                        let weekdayMap: [String: Int] = [
                            "Sun": 1, "Mon": 2, "Tue": 3, "Wed": 4,
                            "Thu": 5, "Fri": 6, "Sat": 7,
                            "Dom": 1, "Lun": 2, "Mar": 3, "Mié": 4, "Jue": 5, "Vie": 6, "Sáb": 7,
                        ]
                        let repeatDays = repeatStrings.compactMap { weekdayMap[$0] }

                        deleteAlarmNotification(identifier: identifier, repeatDays: repeatDays)
                        scheduleAlarmNotification(hour: hour, minute: minute, identifier: identifier, repeatDays: repeatDays)
                    }
                }
            }
        }
    }

    private func deleteAlarmNotification(identifier: String, repeatDays: [Int]) {
        let center = UNUserNotificationCenter.current()
        if repeatDays.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: [identifier])
        } else {
            let ids = repeatDays.map { "\(identifier)_\($0)" }
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    private func scheduleAlarmNotification(hour: Int, minute: Int, identifier: String, repeatDays: [Int]) {
        let content = UNMutableNotificationContent()
        content.title = AppHelper.getLocalizeString(str: "Medication Alert")
        content.body = AppHelper.getLocalizeString(str: "Please take your medication to stay healthy")
        content.categoryIdentifier = "ALARM_CATEGORY"
        content.interruptionLevel = .critical
        content.sound = UNNotificationSound.criticalSoundNamed(UNNotificationSoundName(rawValue: "bell.mp3"))

        let priorMinutes = UserDefaults.standard.integer(forKey: "alarmPriorMinutes")
        var originalComponents = DateComponents()
        originalComponents.hour = hour
        originalComponents.minute = minute

        let calendar = Calendar.current
        guard let originalDate = calendar.date(from: originalComponents),
              let adjustedDate = calendar.date(byAdding: .minute, value: -priorMinutes, to: originalDate) else { return }

        let adjustedComponents = calendar.dateComponents([.hour, .minute], from: adjustedDate)
        let adjustedHour = adjustedComponents.hour ?? hour
        let adjustedMinute = adjustedComponents.minute ?? minute

        if repeatDays.isEmpty {
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
            dateComponents.hour = adjustedHour
            dateComponents.minute = adjustedMinute
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { _ in }
        } else {
            for day in repeatDays {
                var dateComponents = DateComponents()
                dateComponents.hour = adjustedHour
                dateComponents.minute = adjustedMinute
                dateComponents.weekday = day
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: "\(identifier)_\(day)", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { _ in }
            }
        }
    }
}

// MARK: - Dose row presentation (SwiftUI + take-all; mirrors `UserMedicationsTableCell`)

@available(iOS 16.0, *)
struct UserMedicationsDosePresentation {
    let alarm: MedicationAlarm
    let timeDisplay: String
    let isTaken: Bool
    let isInteractive: Bool

    static func build(record: MedicineDetails, timeSlot: TimeSlot) -> UserMedicationsDosePresentation? {
        guard let medical = record.medicationDetailsByDate.first?.medicalDetails else { return nil }

        let pairs = enabledAlarmPairs(medical: medical)
        let chosen: (Int, MedicationAlarm)? = {
            switch timeSlot {
            case .morning: return pairs.first { $0.1.medicineTime.isDayTimeAM() }
            case .afternoon: return pairs.first { $0.1.medicineTime.isDayTimePM() }
            case .evening: return pairs.first { $0.1.medicineTime.isDayTimeEvening() }
            }
        }()
        guard let (_, alarm) = chosen else { return nil }

        let timeText = alarm.medicineTime.getDayTimeFromDate(formatter: "HH:mm:ss", includeTimeZone: true) ?? ""
        let isTaken = alarm.medicineTaken == "1"

        let calendar = Calendar.current
        let now = Date()
        let fourDaysAgo = calendar.date(byAdding: .day, value: -5, to: now)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        guard let medicationDateParsed = dateFormatter.date(from: record.date) else { return nil }

        let isWithinAllowedRange = (medicationDateParsed >= fourDaysAgo) && (medicationDateParsed <= now)
        let today = calendar.startOfDay(for: now)
        let fourDaysAgoFromToday = calendar.date(byAdding: .day, value: -5, to: today)!
        let isInAllowedWindow = medicationDateParsed >= fourDaysAgoFromToday && medicationDateParsed <= today

        let isFuture = checkIsFutureDose(medicationDate: record.date, medicineTime: alarm.medicineTime, now: now, calendar: calendar)
        let isDisabled = !isInAllowedWindow || !isWithinAllowedRange || isFuture

        return UserMedicationsDosePresentation(
            alarm: alarm,
            timeDisplay: timeText,
            isTaken: isTaken,
            isInteractive: !isDisabled
        )
    }

    private static func enabledAlarmPairs(medical: MedicalDetails) -> [(Int, MedicationAlarm)] {
        var out: [(Int, MedicationAlarm)] = []
        for (i, group) in medical.scheduledTimeList.enumerated() {
            for t in group.scheduledTimes where t.isDefault == 0 {
                out.append((i, t))
            }
        }
        return out
    }

    private static func checkIsFutureDose(medicationDate: String, medicineTime: String, now: Date, calendar: Calendar) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        guard let dateOnly = dateFormatter.date(from: medicationDate),
              let hour = Int(medicineTime.prefix(2)) else {
            return false
        }
        if calendar.isDateInToday(dateOnly) {
            return false
        }
        if let scheduled = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: dateOnly),
           now < scheduled {
            return true
        }
        return false
    }
}
