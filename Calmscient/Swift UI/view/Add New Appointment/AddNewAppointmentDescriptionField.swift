//
//  AddNewAppointmentDescriptionField.swift
//  Calmscient
//
//  Multiline appointment detail editor with placeholder.
//
//  Vivek
//  15 May 2026
//

import SwiftUI

struct AddNewAppointmentDescriptionField: View {
    @Binding var text: String
    let placeholder: String
    let isPlaceholderActive: Bool
    @FocusState.Binding var focusedField: AddNewAppointmentFormField?
    let onFocusChanged: (Bool) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(AppHelper.getLocalizeString(str: "Appointment Detail"))
                .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                .foregroundStyle(LoginDesignSystem.ColorName.titleGray)

            ZStack(alignment: .topLeading) {
                if isPlaceholderActive, text.isEmpty {
                    Text(placeholder)
                        .font(LoginDesignSystem.Typography.lexendLight(size: 16))
                        .foregroundStyle(Color.gray.opacity(0.6))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                }

                TextEditor(text: $text)
                    .focused($focusedField, equals: .description)
                    .font(LoginDesignSystem.Typography.lexendLight(size: 16))
                    .foregroundStyle(LoginDesignSystem.ColorName.navy)
                    .frame(minHeight: 100)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .onChange(of: focusedField) { newValue in
                        onFocusChanged(newValue == .description)
                    }
            }
            .background(Color("lightF2F2F2Color"))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color("light6E6BB3Color"), lineWidth: 1)
            )
        }
    }
}

#if DEBUG
private struct AddNewAppointmentDescriptionField_PreviewsHost: View {
    @FocusState private var focusedField: AddNewAppointmentFormField?
    @State private var text = ""
    @State private var placeholderActive = true

    var body: some View {
        AddNewAppointmentDescriptionField(
            text: $text,
            placeholder: "Enter appointment details",
            isPlaceholderActive: placeholderActive,
            focusedField: $focusedField,
            onFocusChanged: { isFocused in
                if isFocused { placeholderActive = false }
            }
        )
        .padding()
        .background(Color("AppBackGroundColor"))
    }
}

#Preview("Description field") {
    AddNewAppointmentDescriptionField_PreviewsHost()
}
#endif
