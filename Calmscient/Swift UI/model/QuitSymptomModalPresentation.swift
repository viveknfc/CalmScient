//
//  QuitSymptomModalPresentation.swift
//  Calmscient
//
//  Localized content for ready-to-quit symptom modals (parity with storyboard VCs).
//
//  Vivek
//  26 May 2026
//

import Foundation
import SwiftUI

enum QuitSymptomTopic: Int, CaseIterable, Identifiable {
    case nicotineCravings = 1
    case irritability
    case difficultyConcentrating
    case increasedAppetite
    case sleepDisturbances
    case depressionAnxiety
    case feelingJumpy

    var id: Int { rawValue }
}

struct QuitSymptomModalContentPresentation: Equatable {
    let title: String
    let blocks: [QuitSymptomModalBlock]
    let goBackButtonTitle: String
}

enum QuitSymptomModalBlock: Equatable {
    case bodyText(String)
    case purpleHeading(String)
    case section(heading: String, body: String)
    case timelineSteps([String])
    case highlighted(fullTextKey: String, accentPhraseKeys: [String])
}

enum QuitSymptomModalPresentation {

    private static let bodyFont = LoginDesignSystem.Typography.lexendLight(size: 15)
    private static let highlightColorName = "6E6BB3ColorOnly"

    static func buildContent(for topic: QuitSymptomTopic) -> QuitSymptomModalContentPresentation {
        QuitSymptomModalContentPresentation(
            title: title(for: topic),
            blocks: blocks(for: topic),
            goBackButtonTitle: "Go back".localized
        )
    }

    static func makeHighlightedAttributedText(
        fullTextKey: String,
        accentPhraseKeys: [String]
    ) -> AttributedString {
        let accentPhrases = accentPhraseKeys.map { $0.localized }
        var attributed = AttributedString(fullTextKey.localized)
        attributed.font = bodyFont
        attributed.foregroundColor = Color.primary

        let accentColor = Color(highlightColorName)
        for phrase in accentPhrases where !phrase.isEmpty {
            var searchStart = attributed.startIndex
            while searchStart < attributed.endIndex,
                  let range = attributed[searchStart...].range(of: phrase) {
                attributed[range].foregroundColor = accentColor
                attributed[range].font = LoginDesignSystem.Typography.lexendMedium(size: 15)
                searchStart = range.upperBound
            }
        }
        return attributed
    }

    private static func title(for topic: QuitSymptomTopic) -> String {
        switch topic {
        case .nicotineCravings:
            return "Nicotine cravings".localized
        case .irritability:
            return "quit_symptom_irritability_title".localized
        case .difficultyConcentrating:
            return "quit_symptom_difficulty_title".localized
        case .increasedAppetite:
            return "Increased appetite and weight gain".localized
        case .sleepDisturbances:
            return "quit_symptom_sleep_title".localized
        case .depressionAnxiety:
            return "quit_symptom_depression_title".localized
        case .feelingJumpy:
            return "quit_symptom_jumpy_title".localized
        }
    }

    private static func blocks(for topic: QuitSymptomTopic) -> [QuitSymptomModalBlock] {
        switch topic {
        case .nicotineCravings: return nicotineBlocks()
        case .irritability: return irritabilityBlocks()
        case .difficultyConcentrating: return difficultyBlocks()
        case .increasedAppetite: return increasedAppetiteBlocks()
        case .sleepDisturbances: return sleepBlocks()
        case .depressionAnxiety: return depressionBlocks()
        case .feelingJumpy: return feelingJumpyBlocks()
        }
    }

    // MARK: - Nicotine cravings

    private static func nicotineBlocks() -> [QuitSymptomModalBlock] {
        [
            .bodyText("quit_symptom_nicotine_intro".localized),
            .purpleHeading("quit_symptom_nicotine_medicines_heading".localized),
            .bodyText("quit_symptom_nicotine_patch_combo".localized),
            .timelineSteps([
                "quit_symptom_nicotine_timeline_patch".localized,
                "quit_symptom_nicotine_timeline_fast_acting".localized,
                "quit_symptom_nicotine_timeline_control".localized,
                "quit_symptom_nicotine_timeline_early_start".localized,
            ]),
            .highlighted(
                fullTextKey: "quit_symptom_nicotine_also_try_full",
                accentPhraseKeys: ["One non-nicotine medicine"]
            ),
            .bodyText("The benefits of Varenicline are:".localized),
            .timelineSteps([
                "quit_symptom_nicotine_timeline_reduces_urge".localized,
                "quit_symptom_nicotine_timeline_strongest_chance".localized,
                "quit_symptom_nicotine_timeline_start_early".localized,
            ]),
            .highlighted(
                fullTextKey: "quit_symptom_nicotine_triggers_full",
                accentPhraseKeys: ["Know your triggers:", "Positive thoughts:"]
            ),
        ]
    }

    // MARK: - Irritability

    private static func irritabilityBlocks() -> [QuitSymptomModalBlock] {
        [
            .bodyText("quit_symptom_irritability_intro".localized),
            .section(
                heading: "quit_symptom_irritability_remind_heading".localized,
                body: "quit_symptom_irritability_remind_body".localized
            ),
            .section(
                heading: "quit_symptom_irritability_breaths_heading".localized,
                body: "quit_symptom_irritability_breaths_body".localized
            ),
            .section(
                heading: "quit_symptom_irritability_why_heading".localized,
                body: "quit_symptom_irritability_why_body".localized
            ),
        ]
    }

    // MARK: - Difficulty concentrating

    private static func difficultyBlocks() -> [QuitSymptomModalBlock] {
        [
            .bodyText("quit_symptom_difficulty_intro".localized),
            .section(
                heading: "quit_symptom_difficulty_kind_heading".localized,
                body: "quit_symptom_difficulty_kind_body".localized
            ),
            .section(
                heading: "quit_symptom_difficulty_easy_heading".localized,
                body: "quit_symptom_difficulty_easy_body".localized
            ),
        ]
    }

    // MARK: - Increased appetite

    private static func increasedAppetiteBlocks() -> [QuitSymptomModalBlock] {
        [
            .bodyText("quit_symptom_appetite_intro".localized),
            .section(
                heading: "quit_symptom_appetite_snacking_heading".localized,
                body: "quit_symptom_appetite_snacking_body".localized
            ),
            .section(
                heading: "quit_symptom_appetite_moving_heading".localized,
                body: "quit_symptom_appetite_moving_body".localized
            ),
            .section(
                heading: "quit_symptom_appetite_focus_heading".localized,
                body: "quit_symptom_appetite_focus_body".localized
            ),
        ]
    }

    // MARK: - Sleep disturbances

    private static func sleepBlocks() -> [QuitSymptomModalBlock] {
        [
            .bodyText("quit_symptom_sleep_intro".localized),
            .section(
                heading: "quit_symptom_sleep_caffeine_heading".localized,
                body: "quit_symptom_sleep_caffeine_body".localized
            ),
            .section(
                heading: "quit_symptom_sleep_patch_heading".localized,
                body: "quit_symptom_sleep_patch_body".localized
            ),
            .section(
                heading: "quit_symptom_sleep_space_heading".localized,
                body: "quit_symptom_sleep_space_body".localized
            ),
            .section(
                heading: "quit_symptom_sleep_active_heading".localized,
                body: "quit_symptom_sleep_active_body".localized
            ),
            .section(
                heading: "quit_symptom_sleep_routine_heading".localized,
                body: "quit_symptom_sleep_routine_body".localized
            ),
        ]
    }

    // MARK: - Feeling jumpy or restless

    private static func feelingJumpyBlocks() -> [QuitSymptomModalBlock] {
        [
            .bodyText("quit_symptom_jumpy_intro".localized),
            .section(
                heading: "quit_symptom_jumpy_move_heading".localized,
                body: "quit_symptom_jumpy_move_body".localized
            ),
            .section(
                heading: "quit_symptom_jumpy_caffeine_heading".localized,
                body: "quit_symptom_jumpy_caffeine_body".localized
            ),
            .purpleHeading("quit_symptom_jumpy_success_heading".localized),
            .timelineSteps([
                "quit_symptom_jumpy_timeline_schedule".localized,
                "quit_symptom_jumpy_timeline_quit_day".localized,
                "quit_symptom_jumpy_timeline_clean".localized,
                "quit_symptom_jumpy_timeline_ashtrays".localized,
                "quit_symptom_jumpy_timeline_medication".localized,
            ]),
        ]
    }

    // MARK: - Depression and anxiety

    private static func depressionBlocks() -> [QuitSymptomModalBlock] {
        [
            .bodyText("quit_symptom_depression_intro".localized),
            .section(
                heading: "quit_symptom_depression_moving_heading".localized,
                body: "quit_symptom_depression_moving_body".localized
            ),
            .section(
                heading: "quit_symptom_depression_busy_heading".localized,
                body: "quit_symptom_depression_busy_body".localized
            ),
            .section(
                heading: "quit_symptom_depression_connect_heading".localized,
                body: "quit_symptom_depression_connect_body".localized
            ),
            .section(
                heading: "quit_symptom_depression_treat_heading".localized,
                body: "quit_symptom_depression_treat_body".localized
            ),
            .purpleHeading("quit_symptom_depression_talk_heading".localized),
            .highlighted(
                fullTextKey: "quit_symptom_depression_talk_body",
                accentPhraseKeys: ["1-800-QUIT-NOW"]
            ),
            .section(
                heading: "quit_symptom_depression_stress_heading".localized,
                body: "quit_symptom_depression_discovery_body".localized
            ),
        ]
    }

    #if DEBUG
    static func previewContent(for topic: QuitSymptomTopic) -> QuitSymptomModalContentPresentation {
        buildContent(for: topic)
    }
    #endif
}
