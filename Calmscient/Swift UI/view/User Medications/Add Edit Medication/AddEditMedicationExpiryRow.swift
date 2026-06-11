//
//  AddEditMedicationExpiryRow.swift
//  Calmscient
//
//  Read-only style expiry date row; opens wheel picker via `onTap`.
//

//  Vivek
//  15 May 2026
//
import SwiftUI

struct AddEditMedicationExpiryRow: View {
    let dateDisplay: String
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Expiry date".localized)
                .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                .foregroundStyle(LoginDesignSystem.ColorName.titleGray)

            Button {
                onTap()
            } label: {
                HStack {
                    Text(dateDisplay.isEmpty ? " " : dateDisplay)
                        .font(LoginDesignSystem.Typography.lexendLight(size: 16))
                        .foregroundStyle(LoginDesignSystem.ColorName.navy)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "calendar")
                        .foregroundStyle(LoginDesignSystem.ColorName.primaryGradientTop)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color("lightF2F2F2Color"))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color("light6E6BB3Color"), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

#if DEBUG
#Preview("Expiry row — empty") {
    AddEditMedicationExpiryRow(dateDisplay: "", onTap: {})
        .padding()
}

#Preview("Expiry row — filled") {
    AddEditMedicationExpiryRow(dateDisplay: "05/22/2026", onTap: {})
        .padding()
}
#endif
