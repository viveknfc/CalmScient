//
//  ConSub2Presentation.swift
//  Calmscient
//
//  Content models for Alcohol-related mental dysfunction (parity with `ConSub2VC`).
//
//  Vivek
//  25 May 2026
//

import Foundation

struct ConSub2ContentPresentation: Equatable {
    let headerTitle: String
    let introText: String
    let numberedItems: [String]
}

enum ConSub2Presentation {

    private static let numberedItemKeys = [
        "DRINKING_CONTROL_Consequence_Sub2_Item_One",
        "DRINKING_CONTROL_Consequence_Sub2_Item_Two",
        "DRINKING_CONTROL_Consequence_Sub2_Item_Three",
    ]

    static func buildLocalizedContent() -> ConSub2ContentPresentation {
        ConSub2ContentPresentation(
            headerTitle: "Alcohol-related mental dysfunction".localized,
            introText: "DRINKING_CONTROL_Consequence_Sub2_Intro".localized,
            numberedItems: numberedItemKeys.map { $0.localized }
        )
    }

    #if DEBUG
    static func previewContent() -> ConSub2ContentPresentation {
        buildLocalizedContent()
    }
    #endif
}
