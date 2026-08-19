//
//  AddNewAppointmentViewModel.swift
//  Calmscient
//
//  SwiftUI state + API parity with legacy `AddNewAppointmentViewController`.
//
//  Vivek
//  15 May 2026
//

import Foundation
import SwiftUI
import UIKit

@MainActor
final class AddNewAppointmentViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    // MARK: - SwiftUI navigation
    //
    // Set by `HomeTabView` when this screen is shown inside the Home `NavigationStack`.
    // While nil, every call below falls through to the existing UIKit push/pop, which is
    // what the still-UIKit Discovery tab uses when it pushes into these screens.
    var onOpenRoute: ((HomeRoute) -> Void)?
    var onClose: (() -> Void)?
    var onCloseToRoot: (() -> Void)?

    /// Wired by `AddNewAppointmentHostingController` on the UIKit path and by
    /// `AddNewAppointmentRoute` on the SwiftUI (Home tab) path. Both now funnel into
    /// `presentDatePickerSheet()` / `presentTimePickerSheet()` below.
    var presentDatePicker: (() -> Void)?
    var presentTimePicker: (() -> Void)?

    /// The bottom-sheet presentation used to live only on the hosting controller, so on
    /// the SwiftUI path tapping Date / Time did nothing at all. The view model owns it
    /// now, mirroring `UserMedicationsViewModel.presentMonthDatePicker()`.
    private let datePickerPresenter = BottomSheetDatePickerPresenter()
    private let timePickerPresenter = BottomSheetDatePickerPresenter()

    let isEditMode: Bool
    private let editPayload: MedicalAppointmentDetailsByDate?

    @Published var patientName: String = ""
    @Published var providerName: String = ""
    @Published var locationName: String = ""
    @Published var dateMMddYYYY: String = ""
    @Published var timeHhmma: String = ""
    @Published var appointmentDescription: String = ""
    @Published var isDescriptionPlaceholderActive: Bool = true
    @Published var alertEnabled: Bool = false

    @Published private(set) var providerSuggestions: [AddNewAppointmentSuggestion] = []
    @Published private(set) var locationSuggestions: [AddNewAppointmentSuggestion] = []
    @Published var activeAutocomplete: AddNewAppointmentFormField?
    @Published private(set) var isLoadingReferenceData: Bool = false
    @Published private(set) var isSaving: Bool = false

    private var locationData: [LocationDetail] = []
    private var providerData: [ProviderDetail] = []
    private var providerId: Int?
    private var locationId: Int?
    private var appointmentId: Int = 0

    private var patientLocationId: Int = 0
    private var patientId: Int = 0
    private var clientId: Int = 0
    private var userId: Int = 0

    /// Title most recently written by `selectSuggestion(_:field:)`. Used to swallow the
    /// single echo SwiftUI sends back through the text-field binding so the dropdown
    /// closes on the first tap. Cleared as soon as the user types anything different.
    private var appliedProviderSuggestionTitle: String?
    private var appliedLocationSuggestionTitle: String?

    private var didApplyEditPayload = false
    private var locationsLoaded = false
    private var providersLoaded = false

    /// Falls back to the key window so this screen still shows toasts when it is
    /// presented without a `hostViewController` (SwiftUI-navigated Home tab).
    private var anchorView: UIView? { Toast.resolvedAnchor(hostViewController?.view) }

    var screenTitle: String {
        isEditMode ? "Edit appointment".localized : "Add appointment".localized
    }

    var descriptionPlaceholder: String {
        "appointment_description_placeholder".localized
    }

    init(isEditMode: Bool, editPayload: MedicalAppointmentDetailsByDate?) {
        self.isEditMode = isEditMode
        self.editPayload = editPayload
    }

    func onHostWillAppear() {
        hostViewController?.title = screenTitle
        patientName = UserDefaults.standard.string(forKey: "titleString") ?? ""

        guard let loginResponse = ApplicationSharedInfo.shared.loginResponse else { return }
        patientLocationId = loginResponse.patientLocationID
        patientId = loginResponse.patientID
        clientId = loginResponse.clientID
        userId = loginResponse.userID

        if !isEditMode {
            appointmentId = 0
            alertEnabled = false
            appointmentDescription = descriptionPlaceholder
            isDescriptionPlaceholderActive = true
        }

        loadReferenceData()
    }

    func dismissAutocomplete() {
        activeAutocomplete = nil
        providerSuggestions = []
        locationSuggestions = []
    }

    func sanitizedField(_ raw: String) -> String {
        raw
            .replacingOccurrences(of: "<", with: "")
            .replacingOccurrences(of: ">", with: "")
            .replacingOccurrences(of: "/", with: "")
    }

    func bindingForProvider() -> Binding<String> {
        Binding(
            get: { self.providerName },
            set: { newValue in
                let cleaned = self.sanitizedField(newValue)
                self.providerName = cleaned
                // Picking a suggestion writes the title into `providerName`, and while the
                // text field is still first responder SwiftUI echoes that programmatic
                // change straight back through this setter. Re-running the search would
                // re-open the dropdown on the very tap that was meant to close it — which
                // is why dismissing it used to take a second tap. The echo carries exactly
                // the applied title, so it is ignored once; any real edit differs and
                // clears the marker.
                guard cleaned != self.appliedProviderSuggestionTitle else { return }
                self.appliedProviderSuggestionTitle = nil
                self.providerId = nil
                self.refreshProviderSuggestions(for: cleaned)
                self.activeAutocomplete = .provider
            }
        )
    }

    func bindingForLocation() -> Binding<String> {
        Binding(
            get: { self.locationName },
            set: { newValue in
                let cleaned = self.sanitizedField(newValue)
                self.locationName = cleaned
                // See `bindingForProvider()` — same post-selection echo guard.
                guard cleaned != self.appliedLocationSuggestionTitle else { return }
                self.appliedLocationSuggestionTitle = nil
                self.locationId = nil
                self.refreshLocationSuggestions(for: cleaned)
                self.activeAutocomplete = .location
            }
        )
    }

    func bindingForDescription() -> Binding<String> {
        Binding(
            get: {
                self.isDescriptionPlaceholderActive ? "" : self.appointmentDescription
            },
            set: { newValue in
                let cleaned = self.sanitizedField(newValue)
                self.isDescriptionPlaceholderActive = false
                self.appointmentDescription = cleaned
            }
        )
    }

    func onDescriptionFocusChanged(isFocused: Bool) {
        if isFocused {
            if isDescriptionPlaceholderActive {
                isDescriptionPlaceholderActive = false
                appointmentDescription = ""
            }
        } else if appointmentDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            isDescriptionPlaceholderActive = true
            appointmentDescription = descriptionPlaceholder
        }
    }

    func onProviderFieldFocused() {
        activeAutocomplete = .provider
        refreshProviderSuggestions(for: providerName)
    }

    func onLocationFieldFocused() {
        activeAutocomplete = .location
        refreshLocationSuggestions(for: locationName)
    }

    func selectSuggestion(_ suggestion: AddNewAppointmentSuggestion, field: AddNewAppointmentFormField) {
        switch field {
        case .provider:
            providerName = suggestion.title
            providerId = suggestion.id
            providerSuggestions = []
            // Stored sanitized because the echo arrives through `sanitizedField(_:)`.
            appliedProviderSuggestionTitle = sanitizedField(suggestion.title)
        case .location:
            locationName = suggestion.title
            locationId = suggestion.id
            locationSuggestions = []
            appliedLocationSuggestionTitle = sanitizedField(suggestion.title)
        default:
            break
        }
        activeAutocomplete = nil
    }

    func toggleAlert() {
        alertEnabled.toggle()
    }

    func openDatePicker() {
        dismissAutocomplete()
        anchorView?.endEditing(true)
        // Falls back to presenting directly when no host wired a closure, so the row is
        // never dead regardless of which navigation path opened this screen.
        if let presentDatePicker {
            presentDatePicker()
        } else {
            presentDatePickerSheet()
        }
    }

    func openTimePicker() {
        dismissAutocomplete()
        anchorView?.endEditing(true)
        if let presentTimePicker {
            presentTimePicker()
        } else {
            presentTimePickerSheet()
        }
    }

    // MARK: - Bottom-sheet date / time pickers
    //
    // Bodies are the ones that previously lived in
    // `AddNewAppointmentHostingController.presentDatePicker()` / `.presentTimePicker()`,
    // moved here so the SwiftUI Home-tab route can reach them too.

    func presentDatePickerSheet() {
        guard let host = hostViewController else { return }
        let configuration = BottomSheetDatePickerConfiguration(
            pickerMode: .date,
            minimumDate: Date(),
            initialDate: Self.mmddyyyyFormatter().date(from: trimmedDateText) ?? Date()
        )
        datePickerPresenter.present(from: host, configuration: configuration) { [weak self] date, isTimePicker in
            guard !isTimePicker else { return }
            self?.applyDateFromPicker(date)
        }
    }

    func presentTimePickerSheet() {
        guard let host = hostViewController else { return }
        let configuration = BottomSheetDatePickerConfiguration(
            pickerMode: .time,
            initialDate: Self.hhmmaFormatter().date(from: trimmedTimeText) ?? Date()
        )
        timePickerPresenter.present(from: host, configuration: configuration) { [weak self] date, isTimePicker in
            guard isTimePicker else { return }
            self?.applyTimeFromPicker(date)
        }
    }

    private var trimmedDateText: String {
        dateMMddYYYY.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedTimeText: String {
        timeHhmma.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func applyDateFromPicker(_ date: Date) {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfSelected = calendar.startOfDay(for: date)
        if startOfSelected < startOfToday {
            anchorView?.showToast(message: "appointment_past_dates_not_allowed".localized)
            return
        }
        dateMMddYYYY = Self.mmddyyyyFormatter().string(from: date)
    }

    func applyTimeFromPicker(_ date: Date) {
        let calendar = Calendar.current
        let now = Date()
        // The "time is in the past" rule only applies once a date has been chosen and
        // that date is today. Previously an unparsable (i.e. still empty) date bailed
        // out early, so picking Time before Date silently left the field blank.
        let selectedDate = Self.mmddyyyyFormatter().date(from: dateMMddYYYY.trimmingCharacters(in: .whitespacesAndNewlines))

        if let selectedDate, calendar.isDateInToday(selectedDate), date < now {
            hostViewController?.showGeneralAlert(
                image: UIImage(named: "InfoIcon"),
                imageSize: CGSize(width: 60, height: 60),
                title: "appointment_selected_time_in_past".localized,
                okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                okAction: {},
                showDismissButton: false
            )
            return
        }

        timeHhmma = Self.hhmmaFormatter().string(from: date)
    }

    func cancel() {
        dismissAutocomplete()
        if let onClose {
            onClose()
            return
        }
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    func saveIfValid() {
        dismissAutocomplete()
        anchorView?.endEditing(true)

        let trimmedPatient = patientName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedProvider = providerName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLocation = locationName.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedPatient.isEmpty {
            showValidationAlert("appointment_validation_patient_name_empty".localized)
            return
        }
        if trimmedProvider.isEmpty {
            showValidationAlert("appointment_validation_provider_name_empty".localized)
            return
        }
        if trimmedLocation.isEmpty {
            showValidationAlert("appointment_validation_location_name_empty".localized)
            return
        }

        guard let isoDateTime = buildISO8601DateTime() else { return }

        let descriptionText: String
        if isDescriptionPlaceholderActive {
            descriptionText = descriptionPlaceholder
        } else {
            descriptionText = appointmentDescription
        }

        var params: [String: Any] = [
            "appointmentId": appointmentId,
            "plId": patientLocationId,
            "patientId": patientId,
            "clientId": clientId,
            "providerFirstName": trimmedProvider,
            "providerLastName": NSNull(),
            "locationName": trimmedLocation,
            "appointmentDateTime": isoDateTime,
            "description": descriptionText,
            "status": "Active",
            "alert": alertEnabled ? 1 : 0,
            "providerId": providerId ?? NSNull(),
            "locationId": locationId ?? NSNull(),
        ]

        guard let host = hostViewController,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else { return }

        isSaving = true
        anchorView?.showToastActivity()

        let completion: (AnyObject) -> Void = { [weak self] response in
            Task { @MainActor in
                self?.handleSaveResponse(response)
            }
        }

        if isEditMode {
            APIService.editSaveAppointmentAPICalling(
                host,
                params: params,
                method: "POST",
                accessToken: token,
                acces: false,
                parameterPlacement: "body",
                callBack: completion
            )
        } else {
            APIService.SaveAppointmentAPICalling(
                host,
                params: params,
                method: "POST",
                accessToken: token,
                acces: false,
                parameterPlacement: "body",
                callBack: completion
            )
        }
    }

    // MARK: - Private

    private func loadReferenceData() {
        guard let host = hostViewController,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else { return }

        isLoadingReferenceData = true
        anchorView?.showToastActivity()

        let locationParams: [String: Int] = ["userId": userId, "clientId": clientId]
        APIService.LocationDetailsAPICalling(
            host,
            params: locationParams,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleLocationResponse(response)
            }
        }

        let providerParams: [String: Int] = ["locationId": patientLocationId, "clientId": clientId]
        
        print("param of providers is \(providerParams)")
        
        APIService.ProviderDetailsAPICalling(
            host,
            params: providerParams,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleProviderResponse(response)
            }
        }
    }

    private func handleLocationResponse(_ response: AnyObject) {
        locationsLoaded = true
        finishReferenceLoadingIfNeeded()

        guard let json = response as? [String: Any],
              let data = try? JSONSerialization.data(withJSONObject: json),
              let decoded = try? JSONDecoder().decode(LocationResponse.self, from: data) else {
            return
        }
        locationData = decoded.locationDetails
        tryApplyEditPayloadIfReady()
    }

    private func handleProviderResponse(_ response: AnyObject) {
        providersLoaded = true
        finishReferenceLoadingIfNeeded()

        guard let json = response as? [String: Any],
              let data = try? JSONSerialization.data(withJSONObject: json),
              let decoded = try? JSONDecoder().decode(ProviderResponse.self, from: data) else {
            return
        }
        providerData = decoded.providerList
        tryApplyEditPayloadIfReady()
    }

    private func finishReferenceLoadingIfNeeded() {
        guard locationsLoaded, providersLoaded else { return }
        isLoadingReferenceData = false
        anchorView?.hideToastActivity()
    }

    private func tryApplyEditPayloadIfReady() {
        guard isEditMode,
              !didApplyEditPayload,
              locationsLoaded,
              providersLoaded,
              let payload = editPayload else { return }

        didApplyEditPayload = true
        let details = payload.appointmentDetails
        let providerNameFromAPI = details.providerName
        let hospitalNameFromAPI = details.hospitalName

        if let matchedProvider = providerData.first(where: { $0.firstName == providerNameFromAPI }) {
            providerId = matchedProvider.providerId
        }
        if let matchedLocation = locationData.first(where: { $0.locationName == hospitalNameFromAPI }) {
            locationId = matchedLocation.locationId
        }

        providerName = providerNameFromAPI
        locationName = hospitalNameFromAPI
        parseAndSetDateTime(from: details.dateAndTime)
        appointmentId = details.appointmentId
        appointmentDescription = details.appointmentDetails
        isDescriptionPlaceholderActive = false
        alertEnabled = (details.alert ?? 0) == 1
    }

    private func parseAndSetDateTime(from isoString: String) {
        let isoFormatter = DateFormatter()
        isoFormatter.locale = Locale(identifier: "en_US")
        isoFormatter.timeZone = TimeZone.current
        isoFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        guard let date = isoFormatter.date(from: isoString) else { return }
        dateMMddYYYY = Self.mmddyyyyFormatter().string(from: date)
        timeHhmma = Self.hhmmaFormatter().string(from: date)
    }

    private func buildISO8601DateTime() -> String? {
        guard let selectedDate = Self.mmddyyyyFormatter().date(from: dateMMddYYYY.trimmingCharacters(in: .whitespacesAndNewlines)),
              let selectedTime = Self.hhmmaFormatter().date(from: timeHhmma.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            showMandatoryFieldsAlert()
            return nil
        }

        let calendar = Calendar.current
        let finalDate = calendar.date(
            bySettingHour: calendar.component(.hour, from: selectedTime),
            minute: calendar.component(.minute, from: selectedTime),
            second: 0,
            of: selectedDate
        ) ?? selectedDate

        let output = DateFormatter()
        output.locale = Locale(identifier: "en_US")
        output.timeZone = TimeZone.current
        output.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return output.string(from: finalDate)
    }

    private func refreshProviderSuggestions(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered: [ProviderDetail]
        if trimmed.isEmpty {
            filtered = providerData
        } else {
            let lower = trimmed.lowercased()
            filtered = providerData.filter {
                $0.firstName.lowercased().contains(lower)
                    || $0.lastName.lowercased().contains(lower)
                    || "\($0.firstName) \($0.lastName)".lowercased().contains(lower)
            }
        }
        providerSuggestions = filtered.map {
            AddNewAppointmentSuggestion(id: $0.providerId, title: "\($0.firstName) \($0.lastName)")
        }
    }

    private func refreshLocationSuggestions(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered: [LocationDetail]
        if trimmed.isEmpty {
            filtered = locationData
        } else {
            let lower = trimmed.lowercased()
            filtered = locationData.filter { $0.locationName.lowercased().contains(lower) }
        }
        locationSuggestions = filtered.map {
            AddNewAppointmentSuggestion(id: $0.locationId, title: $0.locationName)
        }
    }

    private func handleSaveResponse(_ response: AnyObject) {
        isSaving = false
        anchorView?.hideToastActivity()

        if let responseDict = response as? [String: Any],
           let responseMessage = responseDict["message"] as? String {
            hostViewController?.showSuccessAlert(successContent: responseMessage, centreImage: nil, okButtonAction: { [weak self] in
                guard let self else { return }
                if let onClose = self.onClose {
                    onClose()
                    return
                }
                self.hostViewController?.navigationController?.popViewController(animated: true)
            })
        } else if let responseString = response as? String, responseString.hasPrefix("Error:") {
            anchorView?.showToast(message: responseString)
        }
    }

    private func showValidationAlert(_ message: String) {
        hostViewController?.showGeneralAlert(
            image: UIImage(named: "InfoIcon"),
            imageSize: CGSize(width: 60, height: 60),
            title: message,
            okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
            okAction: {},
            showDismissButton: false
        )
    }

    private func showMandatoryFieldsAlert() {
        hostViewController?.showGeneralAlert(
            image: UIImage(named: "InfoIcon"),
            imageSize: CGSize(width: 40, height: 40),
            title: "appointment_validation_mandatory_fields".localized,
            okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
            okAction: {},
            showDismissButton: false
        )
    }

    private static func mmddyyyyFormatter() -> DateFormatter {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US")
        df.timeZone = TimeZone.current
        df.dateFormat = "MM/dd/yyyy"
        return df
    }

    private static func hhmmaFormatter() -> DateFormatter {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US")
        df.timeZone = TimeZone.current
        df.dateFormat = "hh:mm a"
        return df
    }
}

struct AddNewAppointmentSuggestion: Identifiable, Equatable {
    let id: Int
    let title: String
}
