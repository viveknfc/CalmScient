//
//  AddNewAppointmentView.swift
//  Calmscient
//
//  SwiftUI add / edit appointment form (parity with legacy storyboard flow).
//
//  Vivek
//  15 May 2026
//

import SwiftUI

struct AddNewAppointmentView: View {

    @ObservedObject var viewModel: AddNewAppointmentViewModel
    @FocusState private var focusedField: AddNewAppointmentFormField?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AddNewAppointmentLabeledTextField(
                    title: AppHelper.getLocalizeString(str: "Patient name"),
                    text: $viewModel.patientName,
                    isReadOnly: true
                )

                AddNewAppointmentAutocompleteField(
                    title: AppHelper.getLocalizeString(str: "Provider name"),
                    text: viewModel.bindingForProvider(),
                    field: .provider,
                    suggestions: viewModel.providerSuggestions,
                    isDropdownVisible: viewModel.activeAutocomplete == .provider,
                    onFocus: { viewModel.onProviderFieldFocused() },
                    onSelect: { viewModel.selectSuggestion($0, field: .provider) },
                    focusedField: $focusedField
                )

                AddNewAppointmentAutocompleteField(
                    title: AppHelper.getLocalizeString(str: "Location"),
                    text: viewModel.bindingForLocation(),
                    field: .location,
                    suggestions: viewModel.locationSuggestions,
                    isDropdownVisible: viewModel.activeAutocomplete == .location,
                    onFocus: { viewModel.onLocationFieldFocused() },
                    onSelect: { viewModel.selectSuggestion($0, field: .location) },
                    focusedField: $focusedField
                )

                AddNewAppointmentDateTimeRow(
                    title: AppHelper.getLocalizeString(str: "Date"),
                    value: viewModel.dateMMddYYYY,
                    systemImageName: "calendar",
                    onTap: {
                        focusedField = nil
                        viewModel.openDatePicker()
                    }
                )

                AddNewAppointmentDateTimeRow(
                    title: AppHelper.getLocalizeString(str: "Time"),
                    value: viewModel.timeHhmma,
                    systemImageName: "clock",
                    onTap: {
                        focusedField = nil
                        viewModel.openTimePicker()
                    }
                )

                AddNewAppointmentDescriptionField(
                    text: viewModel.bindingForDescription(),
                    placeholder: viewModel.descriptionPlaceholder,
                    isPlaceholderActive: viewModel.isDescriptionPlaceholderActive,
                    focusedField: $focusedField,
                    onFocusChanged: { viewModel.onDescriptionFocusChanged(isFocused: $0) }
                )

                AddNewAppointmentNotificationRow(
                    isEnabled: viewModel.alertEnabled,
                    onToggle: { viewModel.toggleAlert() }
                )

                AddEditMedicationSaveCancelBar(
                    onCancel: {
                        focusedField = nil
                        viewModel.cancel()
                    },
                    onSave: {
                        focusedField = nil
                        viewModel.saveIfValid()
                    }
                )
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
        }
        .background(Color("AppBackGroundColor").ignoresSafeArea())
    }
}

#if DEBUG
#Preview("Add appointment") {
    NavigationView {
        AddNewAppointmentView(
            viewModel: AddNewAppointmentViewModel(isEditMode: false, editPayload: nil)
        )
        .navigationTitle("Add appointment")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Edit appointment") {
    NavigationView {
        AddNewAppointmentView(
            viewModel: AddNewAppointmentViewModel(isEditMode: true, editPayload: nil)
        )
        .navigationTitle("Edit appointment")
        .navigationBarTitleDisplayMode(.inline)
    }
}
#endif
