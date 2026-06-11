//
//  ThinkingAboutQuittingPresentation.swift
//  Calmscient
//
//  Localized content for the thinking-about-quitting screen (parity with `ThinkingAbtQuitingVC`).
//
//  Vivek
//  26 May 2026
//

import Foundation

enum ThinkingAboutQuittingPresentation {

    private static let bodyParagraphKeys = [
        "thinking_about_quitting_body_paragraph_1",
        "thinking_about_quitting_body_paragraph_2",
    ]

    static func buildLocalizedContent() -> SmokingEducationContentPresentation {
        SmokingEducationContentPresentation(
            headerTitle: "thinking_about_quitting_header".localized,
            bodyParagraphs: bodyParagraphKeys.map { $0.localized }
        )
    }
}
