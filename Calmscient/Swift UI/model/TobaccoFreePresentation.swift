//
//  TobaccoFreePresentation.swift
//  Calmscient
//
//  Localized content for the tobacco-free screen (parity with `TobaccoFreeVC`).
//
//  Vivek
//  26 May 2026
//

import Foundation

enum TobaccoFreePresentation {

    private static let bodyParagraphKeys = [
        "tobacco_free_body_paragraph_1",
        "tobacco_free_body_paragraph_2",
        "tobacco_free_body_paragraph_3",
        "tobacco_free_body_paragraph_4",
        "tobacco_free_body_paragraph_5",
    ]

    static func buildLocalizedContent() -> SmokingEducationContentPresentation {
        SmokingEducationContentPresentation(
            headerTitle: "tobacco_free_header".localized,
            bodyParagraphs: bodyParagraphKeys.map { $0.localized }
        )
    }
}
