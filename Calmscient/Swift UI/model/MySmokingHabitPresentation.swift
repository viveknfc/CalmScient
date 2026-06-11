//
//  MySmokingHabitPresentation.swift
//  Calmscient
//
//  Localization keys and stage card content for My Smoking Habit (parity with `MySmokingHabitVC`).
//
//  Vivek
//  26 May 2026
//

import Foundation

enum MySmokingHabitLocalization {
    static let navigationTitleKey = "Basic Knowledge"
    static let headerTitle = "smoking_habit_header_title"
    static let stageQuestion = "smoking_habit_stage_question"
    static let journalPrompt = "Save it to weekly summary journal entry"
    static let yesButton = "Yes"
    static let completeButton = "Complete"
    static let selectStageAlert = "Please select the stage that applies to you."
    static let completeGuideAlert = "We will guide you to create a strategic plan in Taking control full version."
    static let okButton = "Ok"
}

struct SmokingHabitStageCardPresentation: Identifiable, Equatable {
    let id: Int
    let titleKey: String
    let bodyKey: String
    var isSelected: Bool

    var localizedTitle: String { titleKey.localized }
    var localizedBody: String { bodyKey.localized }

    /// Journal API `entry` uses the localized stage title (parity with UIKit).
    var journalEntryValue: String { localizedTitle }
}

enum MySmokingHabitPresentation {

    static func buildLocalizedCards(selectedIndex: Int? = nil) -> [SmokingHabitStageCardPresentation] {
        templates.enumerated().map { index, template in
            SmokingHabitStageCardPresentation(
                id: index,
                titleKey: template.titleKey,
                bodyKey: template.bodyKey,
                isSelected: selectedIndex == index
            )
        }
    }

    private static let templates: [(titleKey: String, bodyKey: String)] = [
        ("smoking_habit_stage_thinking_title", "smoking_habit_stage_thinking_body"),
        ("smoking_habit_stage_ready_title", "smoking_habit_stage_ready_body"),
        ("smoking_habit_stage_quitting_title", "smoking_habit_stage_quitting_body"),
        ("smoking_habit_stage_smokefree_title", "smoking_habit_stage_smokefree_body"),
    ]
}
