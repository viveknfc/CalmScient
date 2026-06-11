//
//  MedicationDetailScheduleRowPresentation.swift
//  Calmscient
//
//  Read-only schedule row UI state mirroring `MedicationsDetailTableCell.updateCellData`.
//

//  Vivek
//  15 May 2026
//
import Foundation

struct MedicationDetailScheduleRowPresentation: Identifiable, Equatable {
    let id: String
    let periodTitle: String
    let timeDisplay: String
    let alarmEnabled: Bool
    /// `true` when `isDefault == 0` (matches selected checkbox image in the legacy cell).
    let isSlotScheduled: Bool

    static func build(from list: ScheduledTimeList) -> MedicationDetailScheduleRowPresentation? {
        guard let scheduledTime = list.scheduledTimes.first else { return nil }

        guard let alarmDayType = scheduledTime.medicineTime.getDayTimeFromDate(formatter: "HH:mm:ss"),
              scheduledTime.alarmTime.getDayTimeFromDate(includeTimeZone: true) != nil else {
            return nil
        }
        guard let dayTypeMatch = DayTimeValue(rawValue: alarmDayType) else { return nil }
        guard let medicineTimeShortForm = scheduledTime.medicineTime.getDayTimeFromDate(formatter: "HH:mm:ss", includeTimeZone: true) else {
            return nil
        }

        let periodTitle: String = {
            switch dayTypeMatch {
            case .Morning: return "Morning".localized
            case .Afternoon: return "Afternoon".localized
            case .Evening: return "Evening".localized
            }
        }()

        let rowId = "\(scheduledTime.pmtId)-\(scheduledTime.alarmId)-\(scheduledTime.medicineTime)"

        return MedicationDetailScheduleRowPresentation(
            id: rowId,
            periodTitle: periodTitle,
            timeDisplay: medicineTimeShortForm,
            alarmEnabled: scheduledTime.alarmEnabled == "1",
            isSlotScheduled: scheduledTime.isDefault == 0
        )
    }

    /// Row state for add / edit medication (mirrors `MedicationsDetailTableCell.updateCellData(medicationAlarm:)`).
    static func from(medicationAlarm alarm: MedicationAlarm, stableId: String) -> MedicationDetailScheduleRowPresentation {
        let periodTitle: String = {
            switch alarm.getDayTime() {
            case .Morning: return "Morning".localized
            case .Afternoon: return "Afternoon".localized
            case .Evening: return "Evening".localized
            }
        }()

        return MedicationDetailScheduleRowPresentation(
            id: stableId,
            periodTitle: periodTitle,
            timeDisplay: alarm.getMedicineTimeWithAMorPM() ?? "",
            alarmEnabled: alarm.alarmEnabled == "1",
            isSlotScheduled: alarm.isDefault == 0
        )
    }
}
