//
//  AddEditMedicationDirectionField.swift
//  Calmscient
//
//  Direction text (multiline on iOS 16+) with 2000 character counter.
//

//  Vivek
//  15 May 2026
//
import SwiftUI

struct AddEditMedicationDirectionField: View {
    @Binding var direction: String
    @FocusState.Binding var focusedField: AddEditMedicationFormField?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AddEditMedicationRequiredTitleView(title: AppHelper.getLocalizeString(str: "Direction"))

            Group {
                if #available(iOS 16.0, *) {
                    TextField("", text: $direction, axis: .vertical)
                        .lineLimit(3...8)
                } else {
                    TextField("", text: $direction)
                }
            }
            .focused($focusedField, equals: .direction)
            .font(LoginDesignSystem.Typography.lexendLight(size: 16))
            .foregroundStyle(LoginDesignSystem.ColorName.navy)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color("lightF2F2F2Color"))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color("light6E6BB3Color"), lineWidth: 1)
            )

            Text("\(direction.count)/2000")
                .font(LoginDesignSystem.Typography.lexendRegular(size: 12))
                .foregroundStyle(LoginDesignSystem.ColorName.footerGray)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

#if DEBUG
private struct AddEditMedicationDirectionField_PreviewsHost: View {
    @FocusState private var focused: AddEditMedicationFormField?
    @State private var direction = "Take with water after meals."

    var body: some View {
        AddEditMedicationDirectionField(direction: $direction, focusedField: $focused)
            .padding()
    }
}

#Preview("Direction field") {
    AddEditMedicationDirectionField_PreviewsHost()
}
#endif
