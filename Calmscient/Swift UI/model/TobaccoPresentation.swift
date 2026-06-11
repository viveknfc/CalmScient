//
//  TobaccoPresentation.swift
//  Calmscient
//
//  Localized content for the tobacco basic knowledge screen.
//
//  Vivek
//  26 May 2026
//

import Foundation

enum TobaccoPresentation {

    private static let bodyParagraphKeys = [
        "tobacco_body_paragraph_1",
        "tobacco_body_paragraph_2",
        "tobacco_body_paragraph_3",
        "tobacco_body_paragraph_4",
        "tobacco_body_paragraph_5",
    ]

    static func buildLocalizedContent() -> SmokingEducationContentPresentation {
        SmokingEducationContentPresentation(
            headerTitle: "tobacco_header".localized,
            bodyParagraphs: bodyParagraphKeys.map { $0.localized }
        )
    }
}
