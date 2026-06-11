//
//  DayFeedbackModels.swift
//  Calmscient
//
//  Screen configuration and static layout data for the post-login day feedback flow.
//
//  Vivek
//  14 May 2026
//
import Foundation

/// Rows mirror `UserIntroDayFeedbackViewController.prepareCellData()` for Morning / Afternoon / Evening.
/// Period rules: `DayFeedbackSessionLogic.moodDayPeriod(for:)`.
@available(iOS 16.0, *)
enum DayFeedbackRow: String, CaseIterable, Hashable {
    case mood
    case focus
    case sleep
    case timeSpend
    case medicine
    case journal

    static func rows(for dayTime: DayTimeValue?) -> [DayFeedbackRow] {
        guard let dayTime else { return [] }
        switch dayTime {
        case .Morning, .Afternoon:
            return [.mood, .focus, .sleep, .medicine, .journal]
        case .Evening:
            return [.mood, .focus, .sleep, .medicine, .journal]
        }
    }
}

enum DayFeedbackLayout {
    static let spendOptionKeys = ["FAMILY", "FRIENDS", "WORKMATES", "OTHERS", "ALONE"]
    static let sleepHourValues = ["3", "4", "5", "6", "7", "8", "9", "10", "11"]

    /// Image asset name, `Localizable.strings` key (same as `UserIntroSelectionTableCell`).
    static let moodOptionPairs: [(String, String)] = [
        ("UserIntro_Bad", "UserIntro_Mood_BAD"),
        ("UserIntro_Couldbe", "UserIntro_Mood_COULD_BE_BETTER"),
        ("UserIntro_Fair", "UserIntro_Mood_FAIR"),
        ("UserIntro_Good", "UserIntro_Mood_GOOD"),
        ("UserIntro_Excellent", "UserIntro_Mood_EXCELLENT")
    ]

    static let timeSpendPairs: [(String, String)] = [
        ("UserIntro_Family", "UserIntro_Time_FAMILY"),
        ("UserIntro_Friends", "UserIntro_Time_FRIENDS"),
        ("UserIntro_Workmates", "UserIntro_Time_WORKMATES"),
        ("UserIntro_Others", "UserIntro_Time_OTHERS"),
        ("UserIntro_Alone", "UserIntro_Time_ALONE")
    ]

    static let selectedFamilyImages = ["family_selected", "friends_selected", "workmates_selected", "others", "alone_selected"]
}
