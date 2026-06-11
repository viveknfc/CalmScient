//
//  TakingControlIntroPresentation.swift
//  Calmscient
//
//  Presentation models for the Taking Control CAGE-AID intro questionnaire.
//
//  Vivek
//  19 May 2026
//

import Foundation
import SwiftUI

enum TakingControlIntroBinaryAnswer: String, Equatable {
    case yes = "Yes"
    case no = "No"
}

struct TakingControlIntroQuestionRowPresentation: Identifiable, Equatable {
    let id: Int
    let questionText: String
    var selectedAnswer: TakingControlIntroBinaryAnswer?
    
    var questionNumber: String {
        let regex = #"^\d+\."#
        return questionText.range(of: regex, options: .regularExpression)
            .map { String(questionText[$0]) }
            ?? ""
    }

    var trimmedQuestionText: String {
        let regex = #"^\d+\.\s*"#
        return questionText.replacingOccurrences(
            of: regex,
            with: "",
            options: .regularExpression
        )
    }
}

enum TakingControlIntroPresentation {

    static func makeIntroAttributedText(
        fullText: String,
        headingFont: Font,
        bodyFont: Font
    ) -> AttributedString {
        let heading1 = "Welcome to taking control!".localized
        let heading2 = "CAGE-AID Questionnaire".localized

        var attributed = AttributedString(fullText)
        attributed.font = bodyFont

        if let range = attributed.range(of: heading1) {
            attributed[range].font = headingFont
        }
        if let range = attributed.range(of: heading2) {
            attributed[range].font = headingFont
        }
        return attributed
    }

}

#if DEBUG
enum TakingControlIntroPreviewData {

    static func sampleQuestions() -> [TakingControlIntroQuestionRowPresentation] {
        [
            TakingControlIntroQuestionRowPresentation(
                id: 1,
                questionText: "1. Have you ever felt that you ought to cut down on your drinking or drug use?",
                selectedAnswer: nil
            ),
            TakingControlIntroQuestionRowPresentation(
                id: 2,
                questionText: "2. Have people annoyed you by criticizing your drinking or drug use?",
                selectedAnswer: .yes
            ),
            TakingControlIntroQuestionRowPresentation(
                id: 3,
                questionText: "3. Have you ever felt bad or Guilty about your drinking or drug use?",
                selectedAnswer: .no
            ),
        ]
    }
}
#endif
