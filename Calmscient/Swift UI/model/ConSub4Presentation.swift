//
//  ConSub4Presentation.swift
//  Calmscient
//
//  Content models for Health problems (parity with `ConSub4VC`).
//
//  Vivek
//  25 May 2026
//

import Foundation

struct ConSub4ContentPresentation: Equatable {
    let headerTitle: String
    let introText: String
    let bulletItems: [String]
}

enum ConSub4Presentation {

    private static let bulletItemKeys = [
        "DRINKING_CONTROL_Consequence_Four_Message_One",
        "DRINKING_CONTROL_Consequence_Four_Message_Two",
        "DRINKING_CONTROL_Consequence_Four_Message_Three",
        "DRINKING_CONTROL_Consequence_Four_Message_Four",
        "DRINKING_CONTROL_Consequence_Four_Message_Five",
        "DRINKING_CONTROL_Consequence_Four_Message_Six",
    ]

    static func buildLocalizedContent() -> ConSub4ContentPresentation {
        ConSub4ContentPresentation(
            headerTitle: "Health problems".localized,
            introText: "DRINKING_CONTROL_Consequence_Four_Intro".localized,
            bulletItems: bulletItemKeys.map { $0.localized }
        )
    }

    #if DEBUG
    static func previewContent() -> ConSub4ContentPresentation {
        buildLocalizedContent()
    }
    #endif
}
