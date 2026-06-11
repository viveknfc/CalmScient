//
//  HoldYourLiquorPresentation.swift
//  Calmscient
//
//  Content models for the hold-your-liquor education screen.
//
//  Vivek
//  25 May 2026
//

import Foundation

struct HoldYourLiquorContentPresentation: Equatable {
    let headerTitle: String
    let bodyParagraphs: [String]
}

enum HoldYourLiquorPresentation {

    private static let bodyParagraphKeys = [
        "hold_your_liquor_body_paragraph_1",
        "hold_your_liquor_body_paragraph_2",
        "hold_your_liquor_body_paragraph_3",
    ]

    static func buildLocalizedContent() -> HoldYourLiquorContentPresentation {
        HoldYourLiquorContentPresentation(
            headerTitle: "hold_your_liquor_header".localized,
            bodyParagraphs: bodyParagraphKeys.map { $0.localized }
        )
    }

    #if DEBUG
    static func previewContent() -> HoldYourLiquorContentPresentation {
        buildLocalizedContent()
    }
    #endif
}
