//
//  SmokingRelaxPresentation.swift
//  Calmscient
//
//  Localized content for the smoking relax basic knowledge screen.
//
//  Vivek
//  26 May 2026
//

import Foundation

enum SmokingRelaxPresentation {

    private static let bodyParagraphKeys = [
        "smoking_relax_body_paragraph_1",
        "smoking_relax_body_paragraph_2",
    ]

    static func buildLocalizedContent() -> SmokingEducationContentPresentation {
        SmokingEducationContentPresentation(
            headerTitle: "smoking_relax_header".localized,
            bodyParagraphs: bodyParagraphKeys.map { $0.localized }
        )
    }
}
