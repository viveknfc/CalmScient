//
//  NextAppointmentsViewModel.swift
//  Calmscient
//
//  State and API parity with legacy `NextAppointmentsViewController`.
//
//  Vivek
//  15 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class NextAppointmentsViewModel: ObservableObject, MedicalCalendarHeaderProviding {

    weak var hostViewController: UIViewController?

    // MARK: - SwiftUI navigation
    //
    // Set by `HomeTabView` when this screen is shown inside the Home `NavigationStack`.
    // While nil, every call below falls through to the existing UIKit push/pop, which is
    // what the still-UIKit Discovery tab uses when it pushes into these screens.
    var onOpenRoute: ((HomeRoute) -> Void)?
    var onClose: (() -> Void)?
    var onCloseToRoot: (() -> Void)?

    var presentFullDatePickerFromBottom: (() -> Void)?

    /// Legacy `NextAppointmentsHostingController.presentMonthDatePickerFromBottom()` —
    /// see the note on `UserMedicationsViewModel.presentMonthDatePicker()`.
    private let monthDatePickerPresenter = BottomSheetDatePickerPresenter()

    func presentMonthDatePicker() {
        guard let host = hostViewController else { return }
        let configuration = BottomSheetDatePickerConfiguration(
            pickerMode: .date,
            initialDate: selectedAnchorDate
        )
        monthDatePickerPresenter.present(from: host, configuration: configuration) { [weak self] date, isTimePicker in
            guard !isTimePicker else { return }
            self?.selectAnchorDateFromMonthPicker(date)
        }
    }

    var selectedCalendarDate: Date { selectedAnchorDate }

    @Published private(set) var selectedAnchorDate: Date = Calendar.current.startOfDay(for: Date())
    @Published private(set) var rows: [NextAppointmentRowPresentation] = []
    @Published private(set) var isLoading: Bool = false

    @Published var navigationChromeTitle: String = ""
    var tabBarHomeTitle: String = ""

    /// Falls back to the key window so this screen still shows toasts when it is
    /// presented without a `hostViewController` (SwiftUI-navigated Home tab).
    private var anchorView: UIView? { Toast.resolvedAnchor(hostViewController?.view) }

    /// Seeds the localized chrome up front so the navigation title is correct on the
    /// very first SwiftUI body evaluation (the UIKit host used to set it in `viewWillAppear`).
    init() {
        reloadLocalizedChrome()
    }

    func onHostWillAppear() {
        reloadLocalizedChrome()
        fetchAppointments(for: selectedAnchorDate)
    }

    func reloadLocalizedChrome() {
        navigationChromeTitle = "Next appointments".localized
        tabBarHomeTitle = "main_tab_bar_home".localized
    }

    func selectCalendarDate(_ date: Date) {
        selectedAnchorDate = Calendar.current.startOfDay(for: date)
        fetchAppointments(for: selectedAnchorDate)
    }

    func selectAnchorDateFromMonthPicker(_ date: Date) {
        selectCalendarDate(date)
    }

    func openBackToMedicalRecords() {
        if let onClose {
            onClose()
            return
        }
        guard let nav = hostViewController?.navigationController else { return }
        nav.pushViewController(UserMedicalRecordsHostingController(), animated: true)
    }

    func openAddAppointment() {
        if let onOpenRoute {
            onOpenRoute(.addNewAppointment)
            return
        }
        guard let nav = hostViewController?.navigationController else { return }
        let vc = AddNewAppointmentHostingController(isEditMode: false, editPayload: nil)
        nav.pushViewController(vc, animated: true)
    }

    func openAppointmentDetail(_ appointment: MedicalAppointmentDetailsByDate) {
        if let onOpenRoute {
            onOpenRoute(.appointmentDetails(RouteBox(appointment)))
            return
        }
        guard let nav = hostViewController?.navigationController else { return }
        nav.pushViewController(AppointmentDetailsHostingController(medicalAppointment: appointment), animated: true)
    }

    func openEditAppointment(_ appointment: MedicalAppointmentDetailsByDate) {
        if let onOpenRoute {
            onOpenRoute(.editAppointment(RouteBox(appointment)))
            return
        }
        guard let nav = hostViewController?.navigationController else { return }
        let vc = AddNewAppointmentHostingController(isEditMode: true, editPayload: appointment)
        nav.pushViewController(vc, animated: true)
    }

    func confirmDeleteAppointment(_ appointment: MedicalAppointmentDetailsByDate) {
        let alert = UIAlertController(
            title: AppHelper.getLocalizeString(str: "Confirm Deletion"),
            message: AppHelper.getLocalizeString(str: "Are you sure you want to delete this appointment?"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: AppHelper.getLocalizeString(str: "No"), style: .cancel))
        alert.addAction(UIAlertAction(title: AppHelper.getLocalizeString(str: "Yes"), style: .destructive) { [weak self] _ in
            self?.deleteAppointment(appointment)
        })
        if let cancel = alert.actions.first(where: { $0.title == AppHelper.getLocalizeString(str: "No") }) {
            cancel.setValue(#colorLiteral(red: 0.431, green: 0.420, blue: 0.702, alpha: 1), forKey: "titleTextColor")
        }
        hostViewController?.present(alert, animated: true)
    }

    // MARK: - Fetch

    func fetchAppointments(for anchorDate: Date) {
        guard let loginResponse = ApplicationSharedInfo.shared.loginResponse else { return }

        isLoading = true
        anchorView?.showToastActivity()

        let weekDays = anchorDate.nextSevenDays()
        let calendar = Calendar.current
        let toDate = calendar.date(byAdding: .day, value: 6, to: anchorDate)

        var params: [String: Any] = [:]
        params["patientLocationId"] = loginResponse.patientLocationID
        params["patientId"] = loginResponse.patientID
        params["clientId"] = loginResponse.clientID
        params["fromDate"] = anchorDate.dateInMMDDYYYYFormat()
        params["toDate"] = toDate?.dateInMMDDYYYYFormat() ?? Date().dateInMMDDYYYYFormat()

        guard let host = hostViewController,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            isLoading = false
            anchorView?.hideToastActivity()
            return
        }
        
        print("the param for fetch appointment is: \(params)")

        APIService.getMedicalAppointmentsAPICalling(
            host,
            params: params,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleFetchAppointmentsResponse(response, weekDays: weekDays)
            }
        }
    }

    private func handleFetchAppointmentsResponse(_ response: AnyObject, weekDays: [Date]) {
        isLoading = false
        anchorView?.hideToastActivity()

        if let errorMessage = response as? String, errorMessage.hasPrefix("Error:") {
            anchorView?.showToast(message: errorMessage.replacingOccurrences(of: "Error: ", with: ""))
            return
        }

        guard let json = response as? [String: Any],
              let data = try? JSONSerialization.data(withJSONObject: json),
              let decoded = try? JSONDecoder().decode(MedicalAppointmentResponse.self, from: data) else {
            anchorView?.showToast(message: "An Unknown error occured. Please check with Admin")
            return
        }

        if decoded.statusResponse.responseCode != 200 {
            anchorView?.showToast(message: decoded.statusResponse.responseMessage)
            return
        }

        scheduleAppointmentAlarms(from: decoded.appointmentDetailsList)
        rows = buildRows(weekDays: weekDays, appointmentLists: decoded.appointmentDetailsList)
    }

    private func buildRows(
        weekDays: [Date],
        appointmentLists: [MedicalAppointmentDetailsList]
    ) -> [NextAppointmentRowPresentation] {
        var tableData: [NextAppointmentRowPresentation] = []

        for datum in weekDays {
            let matched = appointmentLists.filter { instance in
                let appointmentDateString = instance.date.getDate().dateToString(format: "MM/dd/yyyy")
                let dateString = datum.dateToString(format: "MM/dd/yyyy")
                return appointmentDateString == dateString
            }

            if matched.isEmpty {
                tableData.append(.empty(dateLabel: datum.dateToString(format: "MM/dd/yyyy")))
            } else {
                var isFirstForDate = true
                for appointmentDetailsList in matched {
                    for eachAppointment in appointmentDetailsList.appointmentDetailsByDate {
                        let updated = eachAppointment
                        updated.dateString = appointmentDetailsList.date.getDate().dateToString(format: "MM/dd/yyyy")
                        updated.showDateLabel = isFirstForDate
                        isFirstForDate = false
                        tableData.append(.appointment(updated, showDateHeader: updated.showDateLabel))
                    }
                }
            }
        }

        return tableData
    }

    private func scheduleAppointmentAlarms(from lists: [MedicalAppointmentDetailsList]) {
        AlarmManager.shared.removeAllAppointmentAlarms()

        for appointmentDateEntry in lists {
            for appointmentWrapper in appointmentDateEntry.appointmentDetailsByDate {
                guard let appointmentDate = appointmentWrapper.appointmentDetails.dateAndTime.toDate(format: "yyyy-MM-dd HH:mm:ss") else {
                    continue
                }

                if appointmentWrapper.appointmentDetails.alert == 1 {
                    let alerts: [(TimeInterval, String, String)] = [
                        (86400, AppHelper.getLocalizeString(str: "Upcoming Appointment"),
                         AppHelper.getLocalizeString(str: "Don’t forget your medical appointment tomorrow")),
                        (7200, AppHelper.getLocalizeString(str: "Upcoming Appointment"),
                         AppHelper.getLocalizeString(str: "Your medical appointment is in 2 hours")),
                    ]

                    for (interval, title, body) in alerts {
                        let alarmTime = appointmentDate.addingTimeInterval(-interval)
                        AlarmManager.shared.scheduleAlarm(
                            at: alarmTime,
                            title: title,
                            body: body,
                            identifier: "appointment_\(appointmentWrapper.appointmentDetails.appointmentId)_\(Int(interval))"
                        )
                    }
                }
            }
        }
    }

    private func deleteAppointment(_ appointment: MedicalAppointmentDetailsByDate) {
        guard let host = hostViewController else { return }
        let appointmentId = appointment.appointmentDetails.appointmentId
        let params: [String: Int] = ["appointmentId": appointmentId]

        anchorView?.showToastActivity()
        APIService.deleteAppointmentAPICalling(
            host,
            params: params,
            method: "POST",
            accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken,
            acces: false,
            parameterPlacement: "url"
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleDeleteResponse(response)
            }
        }
    }

    private func handleDeleteResponse(_ response: AnyObject) {
        anchorView?.hideToastActivity()

        if let responseDict = response as? [String: Any],
           let responseMessage = responseDict["responseMessage"] as? String {
            hostViewController?.showGeneralAlert(
                image: UIImage(named: "InfoIcon"),
                imageSize: CGSize(width: 60, height: 60),
                title: responseMessage,
                okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                okAction: {},
                showDismissButton: false
            )
            fetchAppointments(for: selectedAnchorDate)
        }
    }
}
