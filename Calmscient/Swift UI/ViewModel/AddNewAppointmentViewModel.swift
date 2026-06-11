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

    var presentDatePicker: (() -> Void)?
    var presentTimePicker: (() -> Void)?

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

    private var didApplyEditPayload = false
    private var locationsLoaded = false
    private var providersLoaded = false

    private var anchorView: UIView? { hostViewController?.view }

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
                self.providerName = self.sanitizedField(newValue)
                self.providerId = nil
                self.refreshProviderSuggestions(for: self.providerName)
                self.activeAutocomplete = .provider
            }
        )
    }

    func bindingForLocation() -> Binding<String> {
        Binding(
            get: { self.locationName },
            set: { newValue in
                self.locationName = self.sanitizedField(newValue)
                self.locationId = nil
                self.refreshLocationSuggestions(for: self.locationName)
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
        case .location:
            locationName = suggestion.title
            locationId = suggestion.id
            locationSuggestions = []
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
        presentDatePicker?()
    }

    func openTimePicker() {
        dismissAutocomplete()
        presentTimePicker?()
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
        guard let selectedDate = Self.mmddyyyyFormatter().date(from: dateMMddYYYY) else { return }

        if calendar.isDateInToday(selectedDate), date < now {
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
                self?.hostViewController?.navigationController?.popViewController(animated: true)
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
