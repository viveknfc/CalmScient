//
//  VapingPresentation.swift
//  Calmscient
//
//  Localized content for the vaping basic knowledge screen.
//
//  Vivek
//  26 May 2026
//

import Foundation

enum VapingPresentation {

    private static let bodyParagraphKeys = [
        "vaping_body_paragraph_1",
        "vaping_body_paragraph_2",
        "vaping_body_paragraph_3",
        "vaping_body_paragraph_4",
    ]

    static func buildLocalizedContent() -> SmokingEducationContentPresentation {
        SmokingEducationContentPresentation(
            headerTitle: "vaping_header".localized,
            bodyParagraphs: bodyParagraphKeys.map { $0.localized },
            referenceURL: "vaping_reference_url".localized
        )
    }
}
