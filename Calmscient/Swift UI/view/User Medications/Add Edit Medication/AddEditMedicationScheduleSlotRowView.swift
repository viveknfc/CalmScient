//
//  AddEditMedicationScheduleSlotRowView.swift
//  Calmscient
//
//  One time slot row: schedule checkbox, time tap, alarm toggle.
//

//  Vivek
//  15 May 2026
//
import SwiftUI

struct AddEditMedicationScheduleSlotRowView: View {
    let row: MedicationDetailScheduleRowPresentation
    let onRowTap: () -> Void
    let onToggleSlot: () -> Void
    let onToggleAlarm: () -> Void

    private var checkboxImageName: String {
        row.isSlotScheduled ? "CellSelectionImage" : "cellUnselectedImage"
    }

    private var alarmToggleImageName: String {
        let base = row.alarmEnabled ? "ToggleSwitch_Yes" : "ToggleSwitch_No"
        return base.localizedImageName
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Button(action: onToggleSlot) {
                Image(checkboxImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)

            Button(action: onRowTap) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(row.periodTitle)
                        .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                        .foregroundStyle(LoginDesignSystem.ColorName.footerGray)

                    Text(row.timeDisplay)
                        .font(LoginDesignSystem.Typography.lexendSemiBold(size: 18))
                        .foregroundStyle(LoginDesignSystem.ColorName.primaryGradientTop)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            VStack(alignment: .trailing, spacing: 6) {
                Text("Alarm".localized)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                    .foregroundStyle(LoginDesignSystem.ColorName.footerGray)

                Button(action: onToggleAlarm) {
                    Image(alarmToggleImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 28)
                        .frame(maxWidth: 120)
                }
                .buttonStyle(.plain)
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
#Preview("Schedule slot — morning") {
    AddEditMedicationScheduleSlotRowView(
        row: MedicationDetailScheduleRowPresentation(
            id: "1",
            periodTitle: "Morning",
            timeDisplay: "08:00 AM",
            alarmEnabled: true,
            isSlotScheduled: true
        ),
        onRowTap: {},
        onToggleSlot: {},
        onToggleAlarm: {}
    )
    .padding()
}

#Preview("Schedule slot — evening off") {
    AddEditMedicationScheduleSlotRowView(
        row: MedicationDetailScheduleRowPresentation(
            id: "3",
            periodTitle: "Evening",
            timeDisplay: "08:00 PM",
            alarmEnabled: false,
            isSlotScheduled: false
        ),
        onRowTap: {},
        onToggleSlot: {},
        onToggleAlarm: {}
    )
    .padding()
}
#endif
