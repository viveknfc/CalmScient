//
//  MedicalCalendarStripLogic.swift
//  Calmscient
//
//  Shared horizontal date strip and month title helpers (medications, appointments, etc.).
//
//  Vivek
//  15 May 2026
//

import Foundation
import Combine

struct MedicalCalendarStripConfiguration {
    let pastDays: Int
    let futureDays: Int

    static let standard = MedicalCalendarStripConfiguration(pastDays: 120, futureDays: 14)
}

enum MedicalCalendarStripLogic {

    static func stripDays(configuration: MedicalCalendarStripConfiguration = .standard) -> [Date] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let total = configuration.pastDays + configuration.futureDays + 1
        return (0..<total).compactMap { offset in
            cal.date(byAdding: .day, value: offset - configuration.pastDays, to: today)
        }
    }

    static func stripDayIdentifier(for day: Date) -> String {
        Calendar.current.startOfDay(for: day).dateToString(format: "yyyy-MM-dd")
    }

    static func isStripDaySelected(_ day: Date, selected: Date) -> Bool {
        let cal = Calendar.current
        return cal.startOfDay(for: day) == cal.startOfDay(for: selected)
    }

    static func monthYearNavigationTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: Utility.shared.getLocaleIdentifier())
        return formatter.string(from: date)
    }
}

@available(iOS 16.0, *)
@MainActor
protocol MedicalCalendarHeaderProviding: ObservableObject {
    var selectedCalendarDate: Date { get }
    var presentFullDatePickerFromBottom: (() -> Void)? { get set }
    func selectCalendarDate(_ date: Date)
}

@available(iOS 16.0, *)
@MainActor
extension MedicalCalendarHeaderProviding {
    func calendarStripDays() -> [Date] {
        MedicalCalendarStripLogic.stripDays()
    }

    func stripDayIdentifier(for day: Date) -> String {
        MedicalCalendarStripLogic.stripDayIdentifier(for: day)
    }

    func isStripDaySelected(_ day: Date) -> Bool {
        MedicalCalendarStripLogic.isStripDaySelected(day, selected: selectedCalendarDate)
    }

    func monthYearNavigationTitle(for date: Date) -> String {
        MedicalCalendarStripLogic.monthYearNavigationTitle(for: date)
    }
}
