//
//  MyDrinkingHabitPresentation.swift
//  Calmscient
//
//  Localization keys and habit card content for My Drinking Habit (parity with `MyDrinkingHabitVC`).
//
//  Vivek
//  25 May 2026
//

import Foundation

enum MyDrinkingHabitLocalization {
    static let navigationTitleKey = "Basic Knowledge"
    static let headerTitle = "drinking_habit_header_title"
    static let habitQuestion = "drinking_habit_question"
    static let moderateDefinitionIntro = "drinking_habit_moderate_definition_intro"
    static let menLabel = "drinking_habit_men_label"
    static let menLimit = "drinking_habit_men_limit"
    static let womenLabel = "drinking_habit_women_label"
    static let womenLimit = "drinking_habit_women_limit"
    static let knowCountsPrompt = "drinking_habit_know_counts_prompt"
    static let calculatorButton = "Drink counts calculator"
    static let journalPrompt = "Save it to weekly summary journal entry"
    static let yesButton = "Yes"
    static let selectStageAlert = "Please select the stage that applies to you."
    static let okButton = "Ok"
    static let forwardFabAccessibility = "drinking_habit_forward_fab_a11y"
}

struct DrinkingHabitCardPresentation: Identifiable, Equatable {
    let id: Int
    let titleKey: String
    let bulletKeys: [String]
    var isSelected: Bool

    var localizedTitle: String { titleKey.localized }
    var localizedBullets: [String] { bulletKeys.map(\.localized) }

    /// Journal API `entry` uses the localized habit title (parity with UIKit).
    var journalEntryValue: String { localizedTitle }
}

enum MyDrinkingHabitPresentation {

    static func buildLocalizedCards(selectedIndex: Int? = nil) -> [DrinkingHabitCardPresentation] {
        templates.enumerated().map { index, template in
            DrinkingHabitCardPresentation(
                id: index,
                titleKey: template.titleKey,
                bulletKeys: template.bulletKeys,
                isSelected: selectedIndex == index
            )
        }
    }

    private static let templates: [(titleKey: String, bulletKeys: [String])] = [
        (
            "Moderate drinking",
            [
                "Always drink with the moderate drinking standard.",
                "Can effortlessly commit alcohol free plan for week or month.",
                "Can choose to drink or not even though people around you are drinking.",
            ]
        ),
        (
            "Moderate everyday drinking",
            [
                "Always drink with the moderate drinking standard but struggles to have alcohol- free day.",
                "Drink daily as sleep aids or relaxation.",
                "Expect to have a drink after work or in the evening and get irritated or stressed when you can't have it.",
            ]
        ),
        (
            "Social / weekend binge drinking",
            [
                "Casual drinking turns into doing things that you normal wouldn't do or that go against your judgement while you're sober, such as driving under alcohol influence.",
                "Often seek the mood-altering effects (the buzz) or using alcohol as a coping mechanism, sometimes in isolation.",
                "Get defensive when someone tries to limit your consumption or asks you to stop.",
                "Remember? Binge drinking is: Men - Up to 5 or more drinks within 2 hrs Women - Up to 4 or more drinks within 2 hrs.",
            ]
        ),
        (
            "Problematic drinking",
            [
                "Drinking until drunk.",
                "Going to work drunk or drinking on the job.",
                "Driving while drunk or have driven while drunk.",
                "Getting in trouble with the law or being injured due to drinking.",
                "Doing something under the influence of alcohol that they would not otherwise do.",
                "Having problems at school, with social relationships, or with family members because of drinking.",
                "Using alcohol to decrease anxiety or sadness.",
                "Lying about or trying to hide drinking habits.",
                "Needing more alcohol to feel its effects.",
                "Feeling grouchy, resentful, or unreasonable when not drinking.",
            ]
        ),
    ]
}
