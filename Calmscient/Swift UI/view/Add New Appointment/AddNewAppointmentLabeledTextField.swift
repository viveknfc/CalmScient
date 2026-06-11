//
//  AddNewAppointmentLabeledTextField.swift
//  Calmscient
//
//  Read-only or editable single-line row on the add-appointment form.
//
//  Vivek
//  15 May 2026
//

import SwiftUI

struct AddNewAppointmentLabeledTextField: View {
    let title: String
    @Binding var text: String
    var isReadOnly: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AddEditMedicationRequiredTitleView(title: title)

            TextField("", text: $text)
                .font(LoginDesignSystem.Typography.lexendLight(size: 16))
                .foregroundStyle(LoginDesignSystem.ColorName.navy)
                .disabled(isReadOnly)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
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
private struct AddNewAppointmentLabeledTextField_PreviewsHost: View {
    @State private var patientName = "Jane Doe"
    @State private var editable = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            AddNewAppointmentLabeledTextField(
                title: "Patient name",
                text: $patientName,
                isReadOnly: true
            )
            AddNewAppointmentLabeledTextField(
                title: "Sample field",
                text: $editable
            )
        }
        .padding()
        .background(Color("AppBackGroundColor"))
    }
}

#Preview("Labeled text field") {
    AddNewAppointmentLabeledTextField_PreviewsHost()
}
#endif
