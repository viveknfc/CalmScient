//
//  AddEditMedicationScheduleSectionView.swift
//  Calmscient
//
//  "Update time & alarm" / "Schedule time & alarm" header and three slot rows.
//

//  Vivek
//  15 May 2026
//
import SwiftUI

struct AddEditMedicationScheduleSectionView: View {
    let sectionTitle: String
    let slotAlarmsVersion: Int
    let rowAt: (Int) -> MedicationDetailScheduleRowPresentation
    let onRowTap: (Int) -> Void
    let onToggleSlot: (Int) -> Void
    let onToggleAlarm: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(sectionTitle)
                .font(LoginDesignSystem.Typography.lexendSemiBold(size: 16))
                .foregroundStyle(LoginDesignSystem.ColorName.navy)

            ForEach(0..<3, id: \.self) { index in
                let row = rowAt(index)
                AddEditMedicationScheduleSlotRowView(
                    row: row,
                    onRowTap: { onRowTap(index) },
                    onToggleSlot: { onToggleSlot(index) },
                    onToggleAlarm: { onToggleAlarm(index) }
                )
                .id("\(index)-\(slotAlarmsVersion)")
            }
        }
    }
}

#if DEBUG
#Preview("Schedule section") {
    AddEditMedicationScheduleSectionView(
        sectionTitle: "Update time & alarm",
        slotAlarmsVersion: 0,
        rowAt: { index in
            let samples = [
                MedicationDetailScheduleRowPresentation(id: "0", periodTitle: "Morning", timeDisplay: "08:00 AM", alarmEnabled: true, isSlotScheduled: true),
                MedicationDetailScheduleRowPresentation(id: "1", periodTitle: "Afternoon", timeDisplay: "01:00 PM", alarmEnabled: true, isSlotScheduled: true),
                MedicationDetailScheduleRowPresentation(id: "2", periodTitle: "Evening", timeDisplay: "08:00 PM", alarmEnabled: false, isSlotScheduled: false),
            ]
            return samples[index]
        },
        onRowTap: { _ in },
        onToggleSlot: { _ in },
        onToggleAlarm: { _ in }
    )
    .padding()
}
#endif
