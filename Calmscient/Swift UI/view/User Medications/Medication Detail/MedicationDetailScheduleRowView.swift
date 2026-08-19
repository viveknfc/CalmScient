//
//  MedicationDetailScheduleRowView.swift
//  Calmscient
//
//  Read-only schedule row (legacy detail screen disabled cell interaction).
//

//  Vivek
//  15 May 2026
//
import SwiftUI

@available(iOS 16.0, *)
struct MedicationDetailScheduleRowView: View {
    let row: MedicationDetailScheduleRowPresentation

    private var checkboxImageName: String {
        row.isSlotScheduled ? "CellSelectionImage" : "cellUnselectedImage"
    }

    private var alarmToggleImageName: String {
        let base = row.alarmEnabled ? "ToggleSwitch_Yes" : "ToggleSwitch_No"
        return base.localizedImageName
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(checkboxImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(row.periodTitle)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                    .foregroundStyle(LoginDesignSystem.ColorName.footerGray)

                Text(row.timeDisplay)
                    .font(LoginDesignSystem.Typography.lexendSemiBold(size: 18))
                    .foregroundStyle(LoginDesignSystem.ColorName.primaryGradientTop)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 6) {
                Text("Alarm".localized)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                    .foregroundStyle(LoginDesignSystem.ColorName.footerGray)

                Image(alarmToggleImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 28)
                    .frame(maxWidth: 120)
                    .accessibilityLabel(row.alarmEnabled ? "Yes".localized : "No".localized)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color("AppViewBorderColor"), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Schedule row — morning") {
    MedicationDetailScheduleRowView(
        row: MedicationDetailScheduleRowPresentation(
            id: "1",
            periodTitle: "Morning",
            timeDisplay: "08:00 AM",
            alarmEnabled: true,
            isSlotScheduled: true
        )
    )
    .padding()
    .background(Color.white)
}

@available(iOS 16.0, *)
#Preview("Schedule row — afternoon off") {
    MedicationDetailScheduleRowView(
        row: MedicationDetailScheduleRowPresentation(
            id: "2",
            periodTitle: "Afternoon",
            timeDisplay: "02:00 PM",
            alarmEnabled: false,
            isSlotScheduled: false
        )
    )
    .padding()
    .background(Color.white)
}
#endif
