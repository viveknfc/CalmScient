//
//  HealthCalendarGridLogic.swift
//  Calmscient
//
//  Month grid maths for the Health Metrics date range popup (same split as
//  `TakingControlCalendarStripLogic`: pure calendar logic here, presentation in
//  the view, state in the view model).
//

import Foundation

// MARK: - Grid models

/// One cell of a month grid. Days spilling in from the neighbouring months are
/// still real dates — they are drawn dimmed and cannot be tapped.
struct HealthCalendarDay: Identifiable, Equatable {
    let id: String              // "yyyy-MM-dd"
    let date: Date
    let dayNumber: String
    let isWithinMonth: Bool
    /// Future days are rendered but cannot be picked.
    let isSelectable: Bool
}

struct HealthCalendarMonth: Identifiable, Equatable {
    let id: String              // "2026-09"
    let title: String           // "September 2026"
    let monthStart: Date
    /// Always six weeks (42 cells) so the popup never changes height.
    let days: [HealthCalendarDay]
}

// MARK: - Builder

enum HealthCalendarGridBuilder {

    static let weeksShown = 6

    /// Weekday initials in the order the current calendar lays a week out.
    static func weekdaySymbols(calendar: Calendar = .current) -> [String] {
        let formatter = DateFormatter()
        formatter.locale = calendar.locale ?? Locale.current
        let symbols = formatter.veryShortStandaloneWeekdaySymbols ?? ["S", "M", "T", "W", "T", "F", "S"]
        let offset = calendar.firstWeekday - 1
        guard offset > 0, offset < symbols.count else { return symbols }
        return Array(symbols[offset...] + symbols[..<offset])
    }

    /// The month grid that contains `date`.
    static func month(containing date: Date,
                      today: Date = Date(),
                      calendar: Calendar = .current) -> HealthCalendarMonth? {
        guard let start = monthStart(of: date, calendar: calendar) else { return nil }
        return month(startingAt: start, today: today, calendar: calendar)
    }

    /// `offset` months away from `monthStart` (negative goes back).
    static func month(byAdding offset: Int,
                      to monthStart: Date,
                      today: Date = Date(),
                      calendar: Calendar = .current) -> HealthCalendarMonth? {
        guard let start = calendar.date(byAdding: .month, value: offset, to: monthStart) else { return nil }
        return month(startingAt: start, today: today, calendar: calendar)
    }

    static func monthStart(of date: Date, calendar: Calendar = .current) -> Date? {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date))
    }

    // MARK: - One month

    private static func month(startingAt start: Date,
                              today: Date,
                              calendar: Calendar) -> HealthCalendarMonth? {

        let endOfToday = calendar.startOfDay(for: today)

        // Back up to the first cell of the week the 1st falls in.
        let weekday = calendar.component(.weekday, from: start)
        let leading = (weekday - calendar.firstWeekday + 7) % 7
        guard let gridStart = calendar.date(byAdding: .day, value: -leading, to: start) else { return nil }

        let monthOfStart = calendar.component(.month, from: start)
        let yearOfStart = calendar.component(.year, from: start)

        var days: [HealthCalendarDay] = []
        for index in 0..<(weeksShown * 7) {
            guard let date = calendar.date(byAdding: .day, value: index, to: gridStart) else { continue }
            let startOfDay = calendar.startOfDay(for: date)
            let isWithinMonth = calendar.component(.month, from: startOfDay) == monthOfStart
                && calendar.component(.year, from: startOfDay) == yearOfStart

            days.append(HealthCalendarDay(
                id: dayIdentifierFormatter.string(from: startOfDay),
                date: startOfDay,
                dayNumber: "\(calendar.component(.day, from: startOfDay))",
                isWithinMonth: isWithinMonth,
                isSelectable: isWithinMonth && startOfDay <= endOfToday))
        }

        return HealthCalendarMonth(
            id: monthIdentifierFormatter.string(from: start),
            title: monthTitleFormatter.string(from: start),
            monthStart: start,
            days: days)
    }

    // MARK: - Formatters

    private static let monthIdentifierFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private static let dayIdentifierFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private static let monthTitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
}
