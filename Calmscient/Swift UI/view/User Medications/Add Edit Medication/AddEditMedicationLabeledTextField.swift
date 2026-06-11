//
//  AddEditMedicationLabeledTextField.swift
//  Calmscient
//
//  Single-line required text field row (medication, provider, dosage).
//

//  Vivek
//  15 May 2026
//
import SwiftUI

struct AddEditMedicationLabeledTextField: View {
    let title: String
    @Binding var text: String
    let field: AddEditMedicationFormField
    var showCounter: Bool = false
    @FocusState.Binding var focusedField: AddEditMedicationFormField?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AddEditMedicationRequiredTitleView(title: title)

            TextField("", text: $text)
                .focused($focusedField, equals: field)
                .font(LoginDesignSystem.Typography.lexendLight(size: 16))
                .foregroundStyle(LoginDesignSystem.ColorName.navy)
                .textInputAutocapitalization(field == .medication ? .sentences : .never)
                .autocorrectionDisabled(field != .medication)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color("lightF2F2F2Color"))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color("light6E6BB3Color"), lineWidth: 1)
                )

            if showCounter {
                Text("\(text.count)/2000")
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 12))
                    .foregroundStyle(LoginDesignSystem.ColorName.footerGray)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

#if DEBUG
private struct AddEditMedicationLabeledTextField_PreviewsHost: View {
    @FocusState private var focused: AddEditMedicationFormField?
    @State private var name = "Aspirin"
    @State private var provider = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            AddEditMedicationLabeledTextField(
                title: "Medication",
                text: $name,
                field: .medication,
                showCounter: false,
                focusedField: $focused
            )
            AddEditMedicationLabeledTextField(
                title: "Provider",
                text: $provider,
                field: .provider,
                showCounter: false,
                focusedField: $focused
            )
        }
        .padding()
    }
}

#Preview("Labeled text field") {
    AddEditMedicationLabeledTextField_PreviewsHost()
}
#endif
