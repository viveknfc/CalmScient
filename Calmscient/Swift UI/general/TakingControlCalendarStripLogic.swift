//
//  TakingControlCalendarStripLogic.swift
//  Calmscient
//
//  Week-scoped date strip helpers for Taking Control (seven days around selected date).
//
//  Vivek
//  20 May 2026
//

import Foundation

enum TakingControlCalendarStripLogic {

    static func weekDays(containing date: Date, calendar: Calendar = .current) -> [Date] {
        let startOfDay = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: startOfDay)
        let startOfWeek = calendar.date(
            byAdding: .day,
            value: -(weekday - calendar.firstWeekday),
            to: startOfDay
        ) ?? startOfDay

        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: startOfWeek)
        }
    }
}
