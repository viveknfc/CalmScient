//
//  AddEditMedicationWithMealRow.swift
//  Calmscient
//
//  With meal toggle using legacy Yes/No image assets.
//

//  Vivek
//  15 May 2026
//
import SwiftUI

struct AddEditMedicationWithMealRow: View {
    @Binding var withMeal: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("With meal".localized)
                .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                .foregroundStyle(LoginDesignSystem.ColorName.titleGray)

            Button {
                withMeal.toggle()
            } label: {
                mealToggleImage(isOn: withMeal)
                    .frame(maxWidth: 160, alignment: .leading)
            }
            .buttonStyle(.plain)
        }
    }

    private func mealToggleImage(isOn: Bool) -> some View {
        let name = isOn ? "ToggleSwitch_Yes".localized : "ToggleSwitch_No".localized
        return Image(name)
            .resizable()
            .scaledToFit()
            .frame(height: 32)
            .frame(maxWidth: 160, alignment: .leading)
            .accessibilityLabel(isOn ? "Yes".localized : "No".localized)
    }
}

#if DEBUG
#Preview("With meal — off") {
    AddEditMedicationWithMealRow(withMeal: .constant(false))
        .padding()
}

#Preview("With meal — on") {
    AddEditMedicationWithMealRow(withMeal: .constant(true))
        .padding()
}
#endif
