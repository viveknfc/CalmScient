//
//  DayFeedbackSessionLogic.swift
//  Calmscient
//
//  Single source for day-feedback period, API timestamps, startup navigation rules,
//  and foreground re-prompt (savedDate / savedTime). Medication alarm buckets use
//  `String.getDayTimeFromDate` and stay separate.
//
//  Vivek
//  20 May 2026
//

import Foundation

enum DayFeedbackSessionLogic {

    // MARK: - UserDefaults (foreground period tracking)

    static let savedDateUserDefaultsKey = "savedDate"
    static let savedTimeUserDefaultsKey = "savedTime"

    private static let nextDayCutoffMinutes = 2 * 60 + 59 // 02:59 AM

    // MARK: - Mood period (device local clock)

    /// Morning: 3:00 AM – 5:59 PM; Evening: 6:00 PM – 2:59 AM (same rules as legacy `getDayTime`).
    static func moodDayPeriod(for date: Date = Date()) -> DayTimeValue {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let totalMinutes = hour * 60 + minute

        switch totalMinutes {
        case (3 * 60)..<(18 * 60):
            return .Morning
        default:
            return .Evening
        }
    }

    // MARK: - API timestamps

    /// `yyyy-MM-dd HH:mm:ss` in `TimeZone.current` (mood fetch/save, startup API).
    static func apiTimestamp(from date: Date = Date()) -> String {
        apiDateTimeFormatter.string(from: date)
    }

    static func userStartupAPIParameters(
        patientLocationId: Int,
        clientId: Int,
        patientId: Int,
        at date: Date = Date()
    ) -> [String: Any] {
        [
            "patientLocationId": patientLocationId,
            "clientId": clientId,
            "patientId": patientId,
            "time": apiTimestamp(from: date),
        ]
    }

    static func moodFetchAPIParameters(
        patientLocationId: Int,
        clientId: Int,
        patientId: Int,
        time: String
    ) -> [String: Any] {
        [
            "patientLocationId": patientLocationId,
            "clientId": clientId,
            "patientId": patientId,
            "time": time,
        ]
    }

    // MARK: - Startup API → show day feedback?

    /// After login (`LoginVC` / `LoginViewModel`): show when `saved != 1`.
    static func shouldShowDayFeedbackAfterLogin(saved: Int) -> Bool {
        saved != 1
    }

    /// Remember Me cold start (`SceneDelegate`): show when `saved == 0`.
    static func shouldShowDayFeedbackOnRememberMe(saved: Int) -> Bool {
        saved == 0
    }

    // MARK: - Last completed period (UserDefaults)

    /// Persists date (`yyyy-MM-dd`) and time (`HH:mm:ss`) in `TimeZone.current`.
    /// SwiftUI: after successful save. UIKit legacy: also on `viewWillAppear`.
    static func recordLastSessionPeriod(at date: Date = Date()) {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.calendar = calendar
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)

        let timeFormatter = DateFormatter()
        timeFormatter.timeZone = TimeZone.current
        timeFormatter.calendar = calendar
        timeFormatter.dateFormat = "HH:mm:ss"
        let timeString = timeFormatter.string(from: date)

        UserDefaults.standard.set(dateString, forKey: savedDateUserDefaultsKey)
        UserDefaults.standard.set(timeString, forKey: savedTimeUserDefaultsKey)
    }

    /// True when the app should show day feedback again after returning to foreground.
    static func shouldPromptDayFeedbackOnForeground(now: Date = Date()) -> Bool {
        let calendar = Calendar.current

        guard
            let savedDateString = UserDefaults.standard.string(forKey: savedDateUserDefaultsKey),
            let savedTimeString = UserDefaults.standard.string(forKey: savedTimeUserDefaultsKey),
            let savedDateTime = combinedSavedDateTime(date: savedDateString, time: savedTimeString)
        else {
            return true
        }

        let savedZone = moodDayPeriod(for: savedDateTime)
        let currentZone = moodDayPeriod(for: now)

        let currentComponents = calendar.dateComponents([.hour, .minute], from: now)
        let currentTotalMinutes = (currentComponents.hour ?? 0) * 60 + (currentComponents.minute ?? 0)

        if !calendar.isDate(savedDateTime, inSameDayAs: now), currentTotalMinutes > nextDayCutoffMinutes {
            UserDefaults.standard.removeObject(forKey: savedDateUserDefaultsKey)
            UserDefaults.standard.removeObject(forKey: savedTimeUserDefaultsKey)
            return true
        }

        return savedZone != currentZone
    }

    // MARK: - Private

    private static let apiDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    private static func combinedSavedDateTime(date: String, time: String) -> Date? {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: "\(date) \(time)")
    }
}
