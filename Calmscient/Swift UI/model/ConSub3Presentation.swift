//
//  ConSub3Presentation.swift
//  Calmscient
//
//  Content models for Alcohol-related blackouts (parity with `ConSub3VC`).
//
//  Vivek
//  25 May 2026
//

import Foundation

struct ConSub3ContentPresentation: Equatable {
    let headerTitle: String
    let bodyText: String
}

enum ConSub3Presentation {

    static func buildLocalizedContent() -> ConSub3ContentPresentation {
        ConSub3ContentPresentation(
            headerTitle: "Alcohol-related blackouts".localized,
            bodyText: "consequences3".localized
        )
    }

    #if DEBUG
    static func previewContent() -> ConSub3ContentPresentation {
        buildLocalizedContent()
    }
    #endif
}
