//
//  AddNewAppointmentAutocompleteField.swift
//  Calmscient
//
//  Provider / location field with inline suggestion list.
//
//  Vivek
//  15 May 2026
//

import SwiftUI

struct AddNewAppointmentAutocompleteField: View {
    let title: String
    @Binding var text: String
    let field: AddNewAppointmentFormField
    let suggestions: [AddNewAppointmentSuggestion]
    let isDropdownVisible: Bool
    let onFocus: () -> Void
    let onSelect: (AddNewAppointmentSuggestion) -> Void

    @FocusState.Binding var focusedField: AddNewAppointmentFormField?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                AddEditMedicationRequiredTitleView(title: title)

                TextField("", text: $text)
                    .focused($focusedField, equals: field)
                    .font(LoginDesignSystem.Typography.lexendLight(size: 16))
                    .foregroundStyle(LoginDesignSystem.ColorName.navy)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color("lightF2F2F2Color"))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color("light6E6BB3Color"), lineWidth: 1)
                    )
                    .onTapGesture { onFocus() }
            }

            if isDropdownVisible, !suggestions.isEmpty {
                VStack(spacing: 0) {
                    ForEach(suggestions) { item in
                        Button {
                            onSelect(item)
                            focusedField = nil
                        } label: {
                            Text(item.title)
                                .font(LoginDesignSystem.Typography.lexendLight(size: 15))
                                .foregroundStyle(LoginDesignSystem.ColorName.navy)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)

                        if item.id != suggestions.last?.id {
                            Divider()
                        }
                    }
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color("light6E6BB3Color"), lineWidth: 1)
                )
                .frame(maxHeight: 150)
                .padding(.top, 4)
                .zIndex(2)
            }
        }
        .zIndex(isDropdownVisible ? 2 : 0)
    }
}

#if DEBUG
private struct AddNewAppointmentAutocompleteField_PreviewsHost: View {
    @FocusState private var focusedField: AddNewAppointmentFormField?
    @State private var providerText = "Dr."
    @State private var locationText = ""

    private let suggestions = [
        AddNewAppointmentSuggestion(id: 1, title: "Dr. Smith"),
        AddNewAppointmentSuggestion(id: 2, title: "Dr. Jones"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            AddNewAppointmentAutocompleteField(
                title: "Provider name",
                text: $providerText,
                field: .provider,
                suggestions: suggestions,
                isDropdownVisible: true,
                onFocus: {},
                onSelect: { _ in },
                focusedField: $focusedField
            )
            AddNewAppointmentAutocompleteField(
                title: "Location",
                text: $locationText,
                field: .location,
                suggestions: [],
                isDropdownVisible: false,
                onFocus: {},
                onSelect: { _ in },
                focusedField: $focusedField
            )
        }
        .padding()
        .background(Color("AppBackGroundColor"))
    }
}

#Preview("Autocomplete field") {
    AddNewAppointmentAutocompleteField_PreviewsHost()
}
#endif
