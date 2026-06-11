//
//  TakingIntroLastModels.swift
//  Calmscient
//
//  Localization keys and attributed text for the Taking Control intro last screen
//  (parity with `TakingIntroLastVC`).
//
//  Vivek
//  20 May 2026
//

import Foundation
import SwiftUI

enum TakingIntroLastLocalization {
    static let screenTitle = "Taking control introduction"
    static let thankYouMessage = "thank_you_message"
    static let thankYouHeading = "thank_you_heading"
    static let dustSection = "text2"
    static let smokingSection = "text3"
    static let footerRetake = "text4"
    static let doNotShowAgain = "text5"
    static let drinkingCoachButton = "taking_intro_last_btn_drinking_coach"
    static let smokingCoachButton = "taking_intro_last_btn_smoking_coach"
    /// Uses existing localized entry whose key is the English phrase.
    static let notifyPcpButtonKeyPhrase = "Notify to PCP"
    static let fabBackAccessibility = "taking_intro_last_fab_back_a11y"
}

enum TakingIntroLastPresentation {

    static func makeThankYouAttributedText(
        fullText: String,
        headingSubstring: String,
        headingFont: Font,
        bodyFont: Font
    ) -> AttributedString {
        var attributed = AttributedString(fullText)
        attributed.font = bodyFont
        if let range = attributed.range(of: headingSubstring) {
            attributed[range].font = headingFont
        }
        return attributed
    }
}
