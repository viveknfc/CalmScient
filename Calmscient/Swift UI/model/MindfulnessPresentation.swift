//
//  MindfulnessPresentation.swift
//  Calmscient
//
//  Six-step mindfulness exercise copy and assets (parity with legacy `MindfulNess`).
//
//  Vivek
//  26 May 2026
//

import Foundation
import SwiftUI

enum MindfulnessIllustrationFit: Equatable {
    case aspectFit
    case aspectFill
}

enum MindfulnessPlainTextStyle: Equatable {
    case bodyLight15
    case titleRegular15
}

enum MindfulnessTextContent: Equatable {
    case none
    case plain(localizedKey: String, style: MindfulnessPlainTextStyle)
    case attributed(AttributedString)
}

struct MindfulnessStepPresentation: Equatable {
    let progressImageName: String
    let illustrationImageName: String
    let illustrationFit: MindfulnessIllustrationFit
    let primaryText: MindfulnessTextContent
    let secondaryText: MindfulnessTextContent
    let showsFavoriteToolbar: Bool
    let showsBackControl: Bool
    let showsForwardControl: Bool
    let showsCompleteButton: Bool
}

enum MindfulnessPresentation {

    static let stepCount = 6
    private static let bodyFontSize: CGFloat = 15

    static func step(at index: Int, isDarkMode: Bool) -> MindfulnessStepPresentation {
        let clamped = min(max(index, 0), stepCount - 1)
        switch clamped {
        case 0: return stepIntro(isDarkMode: isDarkMode)
        case 1: return stepOpposite(isDarkMode: isDarkMode)
        case 2: return stepAnxiety(isDarkMode: isDarkMode)
        case 3: return stepReminder(isDarkMode: isDarkMode)
        case 4: return stepExample(isDarkMode: isDarkMode)
        default: return stepDailyRoutine(isDarkMode: isDarkMode)
        }
    }

    // MARK: - Steps

    private static func stepIntro(isDarkMode: Bool) -> MindfulnessStepPresentation {
        MindfulnessStepPresentation(
            progressImageName: "step1",
            illustrationImageName: "stpe1_img",
            illustrationFit: .aspectFit,
            primaryText: .attributed(
                leadingHighlightBody(
                    highlightKey: "mindfulness_intro_highlight",
                    bodyKey: "mindfulness_intro_body",
                    isDarkMode: isDarkMode
                )
            ),
            secondaryText: .attributed(
                inlineHighlight(
                    fullTextKey: "mindfulness_auto_pilot_text",
                    highlightKey: "mindfulness_auto_pilot_highlight",
                    isDarkMode: isDarkMode
                )
            ),
            showsFavoriteToolbar: false,
            showsBackControl: false,
            showsForwardControl: true,
            showsCompleteButton: false
        )
    }

    private static func stepOpposite(isDarkMode: Bool) -> MindfulnessStepPresentation {
        MindfulnessStepPresentation(
            progressImageName: "step2",
            illustrationImageName: "step2_img",
            illustrationFit: .aspectFit,
            primaryText: .attributed(
                multiInlineHighlight(
                    fullTextKey: "mindfulness_opposite_text",
                    highlightKeys: [
                        "mindfulness_opposite_highlight_primary",
                        "mindfulness_opposite_highlight_secondary",
                    ],
                    isDarkMode: isDarkMode
                )
            ),
            secondaryText: .none,
            showsFavoriteToolbar: false,
            showsBackControl: true,
            showsForwardControl: true,
            showsCompleteButton: false
        )
    }

    private static func stepAnxiety(isDarkMode: Bool) -> MindfulnessStepPresentation {
        MindfulnessStepPresentation(
            progressImageName: "step3",
            illustrationImageName: "step3_img",
            illustrationFit: .aspectFit,
            primaryText: .plain(localizedKey: "mindfulness_anxiety_title", style: .titleRegular15),
            secondaryText: .plain(localizedKey: "mindfulness_anxiety_body", style: .bodyLight15),
            showsFavoriteToolbar: false,
            showsBackControl: true,
            showsForwardControl: true,
            showsCompleteButton: false
        )
    }

    private static func stepReminder(isDarkMode: Bool) -> MindfulnessStepPresentation {
        MindfulnessStepPresentation(
            progressImageName: "step4",
            illustrationImageName: "step4_img",
            illustrationFit: .aspectFill,
            primaryText: .plain(localizedKey: "mindfulness_reminder_body", style: .bodyLight15),
            secondaryText: .none,
            showsFavoriteToolbar: false,
            showsBackControl: true,
            showsForwardControl: true,
            showsCompleteButton: false
        )
    }

    private static func stepExample(isDarkMode: Bool) -> MindfulnessStepPresentation {
        MindfulnessStepPresentation(
            progressImageName: "step5",
            illustrationImageName: "step5_img",
            illustrationFit: .aspectFit,
            primaryText: .plain(localizedKey: "mindfulness_example_body", style: .bodyLight15),
            secondaryText: .none,
            showsFavoriteToolbar: false,
            showsBackControl: true,
            showsForwardControl: true,
            showsCompleteButton: false
        )
    }

    private static func stepDailyRoutine(isDarkMode: Bool) -> MindfulnessStepPresentation {
        MindfulnessStepPresentation(
            progressImageName: "step6",
            illustrationImageName: "step6_img",
            illustrationFit: .aspectFit,
            primaryText: .plain(localizedKey: "mindfulness_daily_routine_body", style: .bodyLight15),
            secondaryText: .none,
            showsFavoriteToolbar: true,
            showsBackControl: true,
            showsForwardControl: false,
            showsCompleteButton: true
        )
    }

    // MARK: - Attributed text

    private static func leadingHighlightBody(
        highlightKey: String,
        bodyKey: String,
        isDarkMode: Bool
    ) -> AttributedString {
        var result = AttributedString()
        var highlight = AttributedString(highlightKey.localized)
        applyHighlightStyle(&highlight, isDarkMode: isDarkMode)

        var body = AttributedString(bodyKey.localized)
        applyBodyStyle(&body, isDarkMode: isDarkMode)

        result.append(highlight)
        result.append(body)
        return result
    }

    private static func inlineHighlight(
        fullTextKey: String,
        highlightKey: String,
        isDarkMode: Bool
    ) -> AttributedString {
        let fullText = fullTextKey.localized
        let highlightPhrase = highlightKey.localized
        var attributed = AttributedString(fullText)
        applyBodyStyle(&attributed, isDarkMode: isDarkMode)

        if let range = attributed.range(of: highlightPhrase) {
            attributed[range].foregroundColor = accentColor(isDarkMode: isDarkMode)
            attributed[range].font = LoginDesignSystem.Typography.lexendLight(size: bodyFontSize)
        }
        return attributed
    }

    private static func multiInlineHighlight(
        fullTextKey: String,
        highlightKeys: [String],
        isDarkMode: Bool
    ) -> AttributedString {
        let fullText = fullTextKey.localized
        var attributed = AttributedString(fullText)
        applyBodyStyle(&attributed, isDarkMode: isDarkMode)

        let accent = accentColor(isDarkMode: isDarkMode)
        let highlightFont = LoginDesignSystem.Typography.lexendLight(size: bodyFontSize)
        for key in highlightKeys {
            let phrase = key.localized
            guard !phrase.isEmpty else { continue }
            var searchStart = attributed.startIndex
            while searchStart < attributed.endIndex,
                  let range = attributed[searchStart...].range(of: phrase) {
                attributed[range].foregroundColor = accent
                attributed[range].font = highlightFont
                searchStart = range.upperBound
            }
        }
        return attributed
    }

    private static func applyHighlightStyle(_ text: inout AttributedString, isDarkMode: Bool) {
        text.font = LoginDesignSystem.Typography.lexendLight(size: bodyFontSize)
        text.foregroundColor = accentColor(isDarkMode: isDarkMode)
    }

    private static func applyBodyStyle(_ text: inout AttributedString, isDarkMode: Bool) {
        text.font = LoginDesignSystem.Typography.lexendLight(size: bodyFontSize)
        text.foregroundColor = bodyColor(isDarkMode: isDarkMode)
    }

    private static func accentColor(isDarkMode: Bool) -> Color {
        isDarkMode ? Color(hex: "#F48383") : Color(hex: "#6E6BB3")
    }

    private static func bodyColor(isDarkMode: Bool) -> Color {
        isDarkMode ? .white : Color(hex: "#110E0E")
    }

    static func plainText(
        for content: MindfulnessTextContent,
        isDarkMode: Bool
    ) -> (text: String, font: Font, color: Color)? {
        guard case .plain(let key, let style) = content else { return nil }
        let font: Font
        switch style {
        case .bodyLight15:
            font = LoginDesignSystem.Typography.lexendLight(size: bodyFontSize)
        case .titleRegular15:
            font = LoginDesignSystem.Typography.lexendRegular(size: bodyFontSize)
        }
        return (key.localized, font, bodyColor(isDarkMode: isDarkMode))
    }

    #if DEBUG
    static func previewStep(index: Int = 0) -> MindfulnessStepPresentation {
        step(at: index, isDarkMode: false)
    }
    #endif
}
