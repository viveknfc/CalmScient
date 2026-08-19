//
//  TimeAndAlarmSheetViewModel.swift
//  Calmscient
//
//  State and save logic for the medication time/alarm bottom sheet
//  (parity with legacy `BottomSheetTimeAndAlarmVC`).
//
//  Scope note: the legacy screen also supported an "existing scheduled time" mode via
//  `instanceObj` / `updateWithUserSelectedDefaults()`, but no caller ever assigned
//  `instanceObj` — the only call site sets `isNewMedicationCreation = true`. That dead
//  branch is not carried over. Its embedded `UITableView` is also omitted: it had a
//  0pt height constraint, `heightForRowAt` returned 0 for both rows, and the caller set
//  `tableView.isHidden = true` — it was never visible.
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class TimeAndAlarmSheetViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    /// Legacy `newMedicationInstance` — kept `weak` exactly as before.
    weak var medicationAlarm: MedicationAlarm?

    @Published var selectedTime: Date = Date()

    private(set) var headingLabelString: String = ""
    private(set) var minimumDate: Date?
    private(set) var maximumDate: Date?

    /// Legacy `tempDateTime` — only written when the picker actually changes,
    /// which is what gates the save side effects.
    private var tempDateTime = ""

    // Legacy write-only bookkeeping, preserved for parity.
    private(set) var timeIdentifier: String? = ""
    private(set) var hourTime: Int?
    private(set) var minTime: Int?
    private(set) var repeatDays: [Int] = []

    var onSheetClosed: (() -> Void)?

    var timeLabelText: String { "Time".localized }

    // MARK: - Configuration (parity with `viewDidLoad` + `updateWithNewMedicationAlarmInstance`)

    func configure(medicationAlarm: MedicationAlarm, headingLabelString: String) {
        self.medicationAlarm = medicationAlarm
        self.headingLabelString = headingLabelString

        let now = medicationAlarm.medicineTime.createDateFromTimeString()
        print("Current date with time \(now)")
        selectedTime = now

        let dateRestrictions = medicationAlarm.getTimeRestrictionsFromDate()
        print("Date Restricitions are \(dateRestrictions)")
        // Legacy indexed `[0]` / `[1]` directly; `getTimeRestrictionsFromDate()` returns
        // an empty array for `dayTime == .none`, which would trap. Guarded here.
        if dateRestrictions.count >= 2 {
            minimumDate = dateRestrictions[0]
            maximumDate = dateRestrictions[1]
        }
    }

    // MARK: - Picker

    /// Parity with `onDateValueChanged(_:)`.
    func onTimeChanged(_ newValue: Date) {
        tempDateTime = newValue.dateToString(format: "HH:mm:ss")
    }

    // MARK: - Actions

    /// Parity with `saveButtonAction(_:)` (new-medication branch).
    func save() {
        medicationAlarm?.isDefault = 0 // 1

        if !tempDateTime.isEmpty {
            let newDateTime = tempDateTime
            medicationAlarm?.medicineTime = newDateTime
            // medicationAlarm?.alarmEnabled = "1"
            timeIdentifier = medicationAlarm?.getAlarmTime()
            print("time identifier is after edit", timeIdentifier as Any)

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            repeatDays = Self.convertDaysToNumbers(days: medicationAlarm?.repeat ?? [])

            // Convert the string back to a Date object
            if let alarmTime = medicationAlarm?.getAlarmTime(),
               let date = dateFormatter.date(from: alarmTime) {
                // Extract hour and minute using Calendar
                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: date)
                let minute = calendar.component(.minute, from: date)

                print("Hour: \(hour), Minute: \(minute)")
                hourTime = hour
                minTime = minute
            } else {
                print("Invalid date format")
            }
        }

        dismiss()
    }

    /// Parity with `closeButtonPressed(_:)`.
    func close() {
        dismiss()
    }

    private func dismiss() {
        hostViewController?.dismiss(animated: true)
    }

    /// Parity with `viewWillDisappear`.
    func onHostWillDisappear() {
        onSheetClosed?()
    }

    // MARK: - Helpers

    /// Moved verbatim from `BottomSheetTimeAndAlarmVC.convertDaysToNumbers(days:)`.
    static func convertDaysToNumbers(days: [String]) -> [Int] {
        let dayMapping: [String: Int] = [
            "Sun": 1,
            "Mon": 2,
            "Tue": 3,
            "Wed": 4,
            "Thu": 5,
            "Fri": 6,
            "Sat": 7,

            "Dom": 1,
            "Lun": 2,
            "Mar": 3,
            "Mié": 4,
            "Jue": 5,
            "Vie": 6,
            "Sáb": 7,
        ]

        let dayNumbers = days.compactMap { dayMapping[$0] }
        return dayNumbers
    }
}
