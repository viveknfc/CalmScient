//
//  AddEditMedicationViewModel.swift
//  Calmscient
//
//  SwiftUI state + API parity with legacy `AddUserMedicationsViewController`.
//

//  Vivek
//  15 May 2026
//
import Foundation
import SwiftUI
import UIKit
import UserNotifications

@MainActor
final class AddEditMedicationViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    var refreshControlClosure: ((Bool) -> Void)?

    let isEditMode: Bool

    @Published var medicationName: String = ""
    @Published var providerName: String = ""
    @Published var dosage: String = ""
    @Published var direction: String = ""
    @Published var withMeal: Bool = false
    @Published var expiryDateMMddYYYY: String = ""

    /// Three rows: morning / afternoon / evening (same references used for save payload).
    @Published private(set) var slotAlarms: [MedicationAlarm] = []

    /// Host presents shared `newPickerViewVC` bottom sheet (see `presentExpiryDatePicker`).
    var presentExpiryDatePicker: (() -> Void)?

    /// Bump to refresh schedule rows when mutating `MedicationAlarm` in place.
    @Published private(set) var slotAlarmsVersion: Int = 0

    private var prescriptionId: Int = 0
    private var anchorView: UIView? { hostViewController?.view }

    weak var medicationFlowHost: AddUserMedicationsViewController?

    init(isEditMode: Bool, medicationData: MedicineDetails?, refreshControlClosure: ((Bool) -> Void)?) {
        self.isEditMode = isEditMode
        self.refreshControlClosure = refreshControlClosure

        if isEditMode, let md = medicationData, let medical = md.medicationDetailsByDate.first?.medicalDetails {
            medicationName = medical.medicineName
            providerName = medical.providerName ?? ""
            dosage = medical.medicineDosage
            direction = medical.directions
            prescriptionId = medical.prescriptionID
            expiryDateMMddYYYY = medical.endDate
            withMeal = medical.withMeal == 1
            slotAlarms = Self.buildSlotAlarmsForEdit(from: medical)
        } else {
            slotAlarms = Self.buildDefaultSlotAlarms()
        }
    }

    func bumpSlotRefresh() {
        slotAlarmsVersion += 1
    }

    var scheduleSectionTitle: String {
        isEditMode ? "Update time & alarm".localized : "Schedule time & alarm".localized
    }

    func onHostWillAppear() {
        if hostViewController?.title == nil || hostViewController?.title?.isEmpty == true {
            hostViewController?.title = AppHelper.getLocalizeString(str: "Add Medications")
        }
    }

    func sanitizedField(_ raw: String, maxLength: Int, allowAngleBrackets: Bool) -> String {
        var t = raw
        if !allowAngleBrackets {
            t = t.replacingOccurrences(of: "<", with: "")
                .replacingOccurrences(of: ">", with: "")
                .replacingOccurrences(of: "/", with: "")
        }
        if t.count > maxLength {
            t = String(t.prefix(maxLength))
        }
        return t
    }

    func bindingForMedicationField(maxLength: Int, allowAngleBrackets: Bool) -> Binding<String> {
        Binding(
            get: { self.medicationName },
            set: { self.medicationName = self.sanitizedField($0, maxLength: maxLength, allowAngleBrackets: allowAngleBrackets) }
        )
    }

    func bindingForProviderField(maxLength: Int, allowAngleBrackets: Bool) -> Binding<String> {
        Binding(
            get: { self.providerName },
            set: { self.providerName = self.sanitizedField($0, maxLength: maxLength, allowAngleBrackets: allowAngleBrackets) }
        )
    }

    func bindingForDosageField(maxLength: Int, allowAngleBrackets: Bool) -> Binding<String> {
        Binding(
            get: { self.dosage },
            set: { self.dosage = self.sanitizedField($0, maxLength: maxLength, allowAngleBrackets: allowAngleBrackets) }
        )
    }

    func bindingForDirectionField() -> Binding<String> {
        Binding(
            get: { self.direction },
            set: { self.direction = self.sanitizedField($0, maxLength: 2000, allowAngleBrackets: false) }
        )
    }

    func openExpiryPicker() {
        presentExpiryDatePicker?()
    }

    func expiryDateForPickerPresentation() -> Date {
        let df = Self.mmddyyyyFormatter()
        if let d = df.date(from: expiryDateMMddYYYY) {
            return Calendar.current.startOfDay(for: d)
        }
        return Calendar.current.startOfDay(for: Date())
    }

    func applyExpiryDateFromPicker(_ date: Date) {
        let reset = Calendar.current.startOfDay(for: date)
        expiryDateMMddYYYY = Self.mmddyyyyFormatter().string(from: reset)
    }

    func confirmCancelEditing() {
        let alert = UIAlertController(
            title: AppHelper.getLocalizeString(str: "Medications"),
            message: AppHelper.getLocalizeString(str: "Are you sure you want to cancel?"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: AppHelper.getLocalizeString(str: "YES"), style: .default) { [weak self] _ in
            self?.hostViewController?.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: AppHelper.getLocalizeString(str: "NO"), style: .cancel))
        hostViewController?.present(alert, animated: true)
    }

    func saveIfValid() {
        anchorView?.endEditing(true)
        guard validateRequiredFields() else { return }

        let medicationData = AddMedication()
        medicationData.direction = direction
        medicationData.dosage = dosage
        medicationData.provider = providerName
        medicationData.medicationName = medicationName
        medicationData.prescriptionId = prescriptionId
        medicationData.providerId = ApplicationSharedInfo.shared.loginResponse?.providerID ?? 0
        medicationData.alarms = slotAlarms
        medicationData.quantity = slotAlarms.count
        medicationData.withMeal = withMeal ? 1 : 0
        medicationData.medicineTime = slotAlarms.first?.medicineTime ?? "13:30:00"
        medicationData.endDate = expiryDateMMddYYYY

        let iValue = isEditMode ? "U" : "I"
        medicationData.pvcFlag = iValue

        for index in medicationData.alarms.indices {
            medicationData.alarms[index].flag = iValue
            medicationData.alarms[index].isEnabled = Int(slotAlarms[index].alarmEnabled ?? "0")
            medicationData.alarms[index].alarmDate = Date().dateToString(format: "MM/dd/yyyy")
            medicationData.alarms[index].medicationId = slotAlarms[index].medicationId ?? 0
            medicationData.alarms[index].pmtId = slotAlarms[index].pmtId
            medicationData.alarms[index].medicineTime = slotAlarms[index].medicineTime
            medicationData.alarms[index].isDefault = slotAlarms[index].isDefault
            medicationData.alarms[index].alarmId = slotAlarms[index].alarmId
        }

        guard let jsonData = try? JSONEncoder().encode(medicationData) else {
            anchorView?.showToast(message: "An Unknown error occured. Please check with Admin".localized)
            return
        }

        anchorView?.showToastActivity()
        APIService.addMedicationsAPICalling(jsonData: jsonData) { [weak self] (response: AddMedicationSavedResponse?, failureResponse: FailureResponse?, error: Error?) in
            Task { @MainActor in
                guard let self else { return }
                self.anchorView?.hideToastActivity()
                if let err = error {
                    self.anchorView?.showToast(message: err.localizedDescription)
                } else if let response = response {
                    let title = response.response.responseMessage
                    self.hostViewController?.showSuccessAlert(successContent: title, okButtonAction: { [weak self] in
                        guard let self, let nav = self.hostViewController?.navigationController else { return }
                        let next = UIStoryboard(name: "UserMedications", bundle: nil)
                        if #available(iOS 16.0, *) {
                            if let vc = next.instantiateViewController(withIdentifier: "UserMedicationsViewController") as? UserMedicationsViewController {
                                nav.pushViewController(vc, animated: true)
                            }
                        } else {
                            // Fallback on earlier versions
                        }
                        self.refreshControlClosure?(true)
                    })
                } else if let failureResponse = failureResponse {
                    self.anchorView?.showToast(message: failureResponse.statusResponse.responseMessage)
                }
            }
        }
    }

    func rowPresentation(at index: Int) -> MedicationDetailScheduleRowPresentation {
        _ = slotAlarmsVersion
        guard slotAlarms.indices.contains(index) else {
            return MedicationDetailScheduleRowPresentation(
                id: "missing-\(index)",
                periodTitle: "",
                timeDisplay: "",
                alarmEnabled: false,
                isSlotScheduled: false
            )
        }
        return MedicationDetailScheduleRowPresentation.from(
            medicationAlarm: slotAlarms[index],
            stableId: "slot-\(index)"
        )
    }

    func setAlarmEnabled(_ enabled: Bool, slotIndex: Int) {
        guard slotAlarms.indices.contains(slotIndex) else { return }
        slotAlarms[slotIndex].alarmEnabled = enabled ? "1" : "0"
        if enabled {
            slotAlarms[slotIndex].isDefault = 0
        } else {
            slotAlarms[slotIndex].isDefault = 1
        }
        bumpSlotRefresh()
    }

    func setSlotScheduled(_ scheduled: Bool, slotIndex: Int) {
        guard slotAlarms.indices.contains(slotIndex) else { return }
        slotAlarms[slotIndex].isDefault = scheduled ? 0 : 1
        bumpSlotRefresh()
    }

    func openTimeAndAlarmSheet(forSlotIndex index: Int) {
        guard slotAlarms.indices.contains(index) else { return }
        checkNotificationPermission(instance: slotAlarms[index])
    }

    func clearDimmingView() {
        medicationFlowHost?.dimmingView?.removeFromSuperview()
        medicationFlowHost?.dimmingView = nil
    }

    // MARK: - Private

    private func validateRequiredFields() -> Bool {
        let name = "Medication".localized
        let provider = "Provider".localized
        let dosage = "Dosage".localized
        let direction = "Direction".localized
        let pleaseEnter = "Please enter".localized

        let pairs: [(String, String)] = [
            (medicationName, name),
            (providerName, provider),
            (self.dosage, dosage),
            (self.direction, direction),
        ]

        for (value, label) in pairs {
            if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let alertText = "\(pleaseEnter) \(label)"
                hostViewController?.showGeneralAlert(
                    image: UIImage(named: "InfoIcon"),
                    imageSize: CGSize(width: 40, height: 40),
                    title: alertText,
                    okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                    okAction: {},
                    dismissAction: {}
                )
                return false
            }
        }
        return true
    }

    private func checkNotificationPermission(instance: MedicationAlarm) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Task { @MainActor in
                switch settings.authorizationStatus {
                case .notDetermined:
                    self.requestNotificationPermission(instance: instance)
                case .denied:
                    self.openAppSettings()
                case .authorized, .provisional, .ephemeral:
                    self.requestNotificationPermission(instance: instance)
                @unknown default:
                    break
                }
            }
        }
    }

    private func requestNotificationPermission(instance: MedicationAlarm) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            Task { @MainActor in
                if granted {
                    self.presentTimeAlarmSheet(instance: instance)
                } else {
                    self.openAppSettings()
                }
            }
        }
    }

    private func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsUrl) else { return }
        UIApplication.shared.open(settingsUrl)
    }

    private func presentTimeAlarmSheet(instance: MedicationAlarm) {
        guard let host = hostViewController else { return }

        let storyboard = UIStoryboard(name: "BottomSheetTimeAndAlarmVC", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "BottomSheetTimeAndAlarmVC") as? BottomSheetTimeAndAlarmVC else {
            return
        }

        vc.isNewMedicationCreation = true
        vc.newMedicationInstance = instance
        vc.onScheetClosed = { [weak self] in
            self?.bumpSlotRefresh()
            self?.clearDimmingView()
        }

        vc.headingLabelString = isEditMode
            ? AppHelper.getLocalizeString(str: "Update Time & Alarm")
            : AppHelper.getLocalizeString(str: "Add Time & Alarm")
        vc.medicineDose = dosage
        vc.medicineName = medicationName

        if let window = host.view.window {
            let dim = UIView(frame: window.bounds)
            dim.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            dim.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            window.addSubview(dim)
            medicationFlowHost?.dimmingView = dim
        }

        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            if let shell = medicationFlowHost {
                sheet.delegate = shell
            }
        }

        vc.loadViewIfNeeded()
        vc.tableView.isHidden = true

        host.present(vc, animated: true)
    }

    private static func mmddyyyyFormatter() -> DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy"
        df.locale = Locale(identifier: "en_US")
        df.timeZone = TimeZone.current
        return df
    }

    private static func buildDefaultSlotAlarms() -> [MedicationAlarm] {
        guard let m = MedicationAlarm(alarmTime2: .Morning),
              let a = MedicationAlarm(alarmTime2: .Afternoon),
              let e = MedicationAlarm(alarmTime2: .Evening) else {
            return decodedPreviewAlarms()
        }
        return [m, a, e]
    }

    private static func buildSlotAlarmsForEdit(from medical: MedicalDetails) -> [MedicationAlarm] {
        var flat: [MedicationAlarm] = []
        for schedule in medical.scheduledTimeList {
            flat.append(contentsOf: schedule.scheduledTimes)
        }
        let templates = buildDefaultSlotAlarms()
        return (0..<3).map { i in
            if i < flat.count {
                return MedicationAlarm.makeDetachedCopy(from: flat[i])
            }
            return MedicationAlarm.makeDetachedCopy(from: templates[i])
        }
    }

    /// Deep-enough copy for editing without mutating cached API models.
    private static func decodedPreviewAlarms() -> [MedicationAlarm] {
        let jsons = [
            """
            {"alarmId":0,"alarmInterval":"05","pmtId":"0","medicineTime":"08:00:00","repeat":["Mon"],"medicineTaken":"0","alarmTime":"2026-05-14 08:00:00","isDefault":0,"alarmEnabled":"1"}
            """,
            """
            {"alarmId":0,"alarmInterval":"05","pmtId":"0","medicineTime":"13:00:00","repeat":["Mon"],"medicineTaken":"0","alarmTime":"2026-05-14 13:00:00","isDefault":0,"alarmEnabled":"1"}
            """,
            """
            {"alarmId":0,"alarmInterval":"05","pmtId":"0","medicineTime":"20:00:00","repeat":["Mon"],"medicineTaken":"0","alarmTime":"2026-05-14 20:00:00","isDefault":1,"alarmEnabled":"0"}
            """,
        ]
        return jsons.compactMap { s in
            guard let d = s.data(using: .utf8),
                  let a = try? JSONDecoder().decode(MedicationAlarm.self, from: d) else { return nil }
            return a
        }
    }
}

private extension MedicationAlarm {
    static func makeDetachedCopy(from source: MedicationAlarm) -> MedicationAlarm {
        let day = source.getDayTime()
        guard let copy = MedicationAlarm(alarmTime2: day) else {
            return source
        }
        copy.medicineTime = source.medicineTime
        copy.alarmTime = source.alarmTime
        copy.alarmId = source.alarmId
        copy.pmtId = source.pmtId
        copy.medicineTaken = source.medicineTaken
        copy.medicineTakenID = source.medicineTakenID
        copy.alarmEnabled = source.alarmEnabled
        copy.alarmInterval = source.alarmInterval
        copy.`repeat` = source.`repeat`
        copy.alarmDate = source.alarmDate
        copy.isEnabled = source.isEnabled
        copy.plId = source.plId
        copy.medicationId = source.medicationId
        copy.flag = source.flag
        copy.isDefault = source.isDefault
        copy.dayTime = source.dayTime
        return copy
    }
}
