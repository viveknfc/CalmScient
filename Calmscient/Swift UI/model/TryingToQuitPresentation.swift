//
//  TryingToQuitPresentation.swift
//  Calmscient
//
//  Localized content for the trying-to-quit screen (parity with `TryingToQuitVC`).
//
//  Vivek
//  26 May 2026
//

import Foundation

struct TryingToQuitContentPresentation: Equatable {
    let headerTitle: String
    let introParagraphs: [String]
    let habitsSectionTitle: String
    let habitBulletItems: [String]
    let rewardsSectionTitle: String
    let celebrationTitle: String
    let milestoneItems: [String]
}

enum TryingToQuitPresentation {

    private static let introParagraphKeys = [
        "trying_to_quit_body_paragraph_1",
        "trying_to_quit_body_paragraph_2",
        "trying_to_quit_body_paragraph_3",
        "trying_to_quit_body_paragraph_4",
    ]

    private static let habitBulletKeys = [
        "trying_to_quit_habit_bullet_1",
        "trying_to_quit_habit_bullet_2",
        "trying_to_quit_habit_bullet_3",
        "trying_to_quit_habit_bullet_4",
        "trying_to_quit_habit_bullet_5",
        "trying_to_quit_habit_bullet_6",
        "trying_to_quit_habit_bullet_7",
    ]

    private static let milestoneKeys = [
        "trying_to_quit_milestone_3_days",
        "trying_to_quit_milestone_7_days",
        "trying_to_quit_milestone_2_weeks",
        "trying_to_quit_milestone_1_month",
        "trying_to_quit_milestone_3_months",
        "trying_to_quit_milestone_6_months",
        "trying_to_quit_milestone_1_year",
    ]

    static func buildLocalizedContent() -> TryingToQuitContentPresentation {
        TryingToQuitContentPresentation(
            headerTitle: "trying_to_quit_header".localized,
            introParagraphs: introParagraphKeys.map { $0.localized },
            habitsSectionTitle: "trying_to_quit_habits_heading".localized,
            habitBulletItems: habitBulletKeys.map { $0.localized },
            rewardsSectionTitle: "trying_to_quit_rewards_heading".localized,
            celebrationTitle: "trying_to_quit_celebrate_heading".localized,
            milestoneItems: milestoneKeys.map { $0.localized }
        )
    }

    #if DEBUG
    static func previewContent() -> TryingToQuitContentPresentation {
        buildLocalizedContent()
    }
    #endif
}
