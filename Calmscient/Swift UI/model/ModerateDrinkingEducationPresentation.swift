//
//  ModerateDrinkingEducationPresentation.swift
//  Calmscient
//
//  Content models for moderate-drinking education screens (parity with legacy moderate VCs).
//
//  Vivek
//  25 May 2026
//

import Foundation
import SwiftUI

enum ModerateDrinkingEducationVariant: Int, CaseIterable {
    case moderateDrinking = 0
    case moderateEveryday = 1
    case socialWeekendBinge = 2
    case problematicDrinking = 3
}

enum ModerateDrinkingEducationBodyBlock: Equatable {
    case plain(String)
    case highlighted(AttributedString)
}

struct ModerateDrinkingEducationContentPresentation: Equatable {
    let headerTitle: String
    let bodyBlocks: [ModerateDrinkingEducationBodyBlock]
}

enum ModerateDrinkingEducationPresentation {

    private static let makeAPlanPhraseKey = "Make a plan"
    private static let myProgressPhraseKey = "My progress"

    static func buildLocalizedContent(
        variant: ModerateDrinkingEducationVariant,
        bodyFont: Font
    ) -> ModerateDrinkingEducationContentPresentation {
        switch variant {
        case .moderateDrinking:
            return ModerateDrinkingEducationContentPresentation(
                headerTitle: "Moderate drinking".localized,
                bodyBlocks: [
                    .plain("moderate_drinking_body_1".localized),
                    .plain("moderate_drinking_body_2".localized),
                    .plain("moderate_drinking_body_3".localized),
                    .highlighted(
                        makeHighlightedBlock(
                            fullTextKey: "moderate_drinking_body_4_full",
                            accentPhraseKeys: [myProgressPhraseKey],
                            bodyFont: bodyFont
                        )
                    ),
                ]
            )
        case .moderateEveryday:
            return ModerateDrinkingEducationContentPresentation(
                headerTitle: "Moderate everyday drinking".localized,
                bodyBlocks: [
                    .plain("moderate_everyday_body_1".localized),
                    .highlighted(
                        makeHighlightedBlock(
                            fullTextKey: "moderate_everyday_body_2_full",
                            accentPhraseKeys: [makeAPlanPhraseKey],
                            bodyFont: bodyFont
                        )
                    ),
                ]
            )
        case .socialWeekendBinge:
            return ModerateDrinkingEducationContentPresentation(
                headerTitle: "Social / weekend binge drinking".localized,
                bodyBlocks: [
                    .plain("moderate_social_binge_body_1".localized),
                    .plain("moderate_social_binge_body_2".localized),
                    .highlighted(
                        makeHighlightedBlock(
                            fullTextKey: "moderate_social_binge_body_3_full",
                            accentPhraseKeys: [makeAPlanPhraseKey],
                            bodyFont: bodyFont
                        )
                    ),
                ]
            )
        case .problematicDrinking:
            return ModerateDrinkingEducationContentPresentation(
                headerTitle: "Problematic drinking".localized,
                bodyBlocks: [
                    .plain("moderate_problematic_body_1".localized),
                    .plain("moderate_problematic_body_2".localized),
                    .highlighted(
                        makeHighlightedBlock(
                            fullTextKey: "moderate_problematic_body_3_full",
                            accentPhraseKeys: [makeAPlanPhraseKey],
                            bodyFont: bodyFont
                        )
                    ),
                ]
            )
        }
    }

    static func makeHighlightedBlock(
        fullTextKey: String,
        accentPhraseKeys: [String],
        bodyFont: Font
    ) -> AttributedString {
        let accentPhrases = accentPhraseKeys.map { $0.localized }
        return ModerationPresentation.makeBodyAttributedText(
            fullText: fullTextKey.localized,
            accentPhrases: accentPhrases,
            bodyFont: bodyFont
        )
    }

    #if DEBUG
    static func previewContent(
        variant: ModerateDrinkingEducationVariant = .moderateDrinking
    ) -> ModerateDrinkingEducationContentPresentation {
        buildLocalizedContent(
            variant: variant,
            bodyFont: LoginDesignSystem.Typography.lexendLight(size: 14)
        )
    }
    #endif
}
