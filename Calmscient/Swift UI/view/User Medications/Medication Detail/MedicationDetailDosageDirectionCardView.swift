//
//  MedicationDetailDosageDirectionCardView.swift
//  Calmscient
//
//  Two-column dosage / directions card (matches legacy bordered `dosageView`).
//

//  Vivek
//  15 May 2026
//
import SwiftUI

@available(iOS 16.0, *)
struct MedicationDetailDosageDirectionCardView: View {
    let dosageLabel: String
    let directionLabel: String
    let dosageText: String
    let directionsText: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(dosageLabel)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 15))
                    .foregroundStyle(Color("MedicationCellTitleColor"))
                Text(dosageText)
                    .font(LoginDesignSystem.Typography.lexendSemiBold(size: 14))
                    .foregroundStyle(.primary)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: 4) {
                Text(directionLabel)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 15))
                    .foregroundStyle(Color("MedicationCellTitleColor"))
                Text(directionsText)
                    .font(LoginDesignSystem.Typography.lexendSemiBold(size: 14))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(4)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(16)
        .background(Color("AppViewContentColor"))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color("AppViewBorderColor"), lineWidth: 1)
        )
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Dosage / direction card") {
    MedicationDetailDosageDirectionCardView(
        dosageLabel: "Dosage".localized,
        directionLabel: "Direction".localized,
        dosageText: "200",
        directionsText: "test nn"
    )
    .padding()
    .background(Color.white)
}
#endif
