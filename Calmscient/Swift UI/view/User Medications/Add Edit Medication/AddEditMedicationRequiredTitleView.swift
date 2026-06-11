//
//  AddEditMedicationRequiredTitleView.swift
//  Calmscient
//
//  Label + red asterisk for required medication form fields.
//

//  Vivek
//  15 May 2026
//
import SwiftUI

struct AddEditMedicationRequiredTitleView: View {
    let title: String

    var body: some View {
        HStack(spacing: 2) {
            Text(title)
                .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                .foregroundStyle(LoginDesignSystem.ColorName.titleGray)
            Text("*")
                .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                .foregroundStyle(Color.red)
        }
    }
}

#if DEBUG
#Preview("Required title") {
    AddEditMedicationRequiredTitleView(title: "Direction")
        .padding()
}
#endif
