//
//  ModerationPresentation.swift
//  Calmscient
//
//  Content models for the moderation education screen.
//
//  Vivek
//  21 May 2026
//

import Foundation
import SwiftUI

struct ModerationContentPresentation: Equatable {
    let headerTitle: String
    let introText: String
    let bulletItems: [String]
    let bodyAttributedText: AttributedString
}

enum ModerationPresentation {

    private static let primaryReasonKeys = [
        "moderation_primary_reason_1",
        "moderation_primary_reason_2",
        "moderation_primary_reason_3",
        "moderation_primary_reason_4",
        "moderation_primary_reason_5",
    ]

    private static let accentPhraseKeys = [
        "moderation_target_women",
        "moderation_target_men",
    ]

    static func makeContent(
        headerTitle: String,
        introText: String,
        bulletItems: [String],
        fullBodyText: String,
        accentPhrases: [String],
        bodyFont: Font
    ) -> ModerationContentPresentation {
        ModerationContentPresentation(
            headerTitle: headerTitle,
            introText: introText,
            bulletItems: bulletItems,
            bodyAttributedText: makeBodyAttributedText(
                fullText: fullBodyText,
                accentPhrases: accentPhrases,
                bodyFont: bodyFont
            )
        )
    }

    static func buildLocalizedContent(bodyFont: Font) -> ModerationContentPresentation {
        let bulletItems = primaryReasonKeys.map { $0.localized }
        let accentPhrases = accentPhraseKeys.map { $0.localized }

        let introText = "moderation_intro_text".localized
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return makeContent(
            headerTitle: "When is drinking in moderation still too much?".localized,
            introText: introText,
            bulletItems: bulletItems,
            fullBodyText: "moderation_full_text".localized,
            accentPhrases: accentPhrases,
            bodyFont: bodyFont
        )
    }

    static func makeBodyAttributedText(
        fullText: String,
        accentPhrases: [String],
        bodyFont: Font
    ) -> AttributedString {
        var attributed = AttributedString(fullText)
        attributed.font = bodyFont
        attributed.foregroundColor = Color("424242Color")

        let accentColor = Color("CustomAlertTitleColor")
        for phrase in accentPhrases where !phrase.isEmpty {
            var searchStart = attributed.startIndex
            while searchStart < attributed.endIndex,
                  let range = attributed[searchStart...].range(of: phrase) {
                attributed[range].foregroundColor = accentColor
                searchStart = range.upperBound
            }
        }
        return attributed
    }

    #if DEBUG
    static func previewContent() -> ModerationContentPresentation {
        buildLocalizedContent(
            bodyFont: LoginDesignSystem.Typography.lexendLight(size: 14)
        )
    }
    #endif
}
