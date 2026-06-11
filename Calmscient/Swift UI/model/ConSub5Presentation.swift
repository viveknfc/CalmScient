//
//  ConSub5Presentation.swift
//  Calmscient
//
//  Content models for Alcohol use disorder (AUD) (parity with `ConSub5VC`).
//
//  Vivek
//  25 May 2026
//

import Foundation

struct ConSub5ContentPresentation: Equatable {
    let headerTitle: String
    let bodyText: String
}

enum ConSub5Presentation {

    static func buildLocalizedContent() -> ConSub5ContentPresentation {
        ConSub5ContentPresentation(
            headerTitle: "Alcohol use disorder (AUD)".localized,
            bodyText: "consequences5".localized
        )
    }

    #if DEBUG
    static func previewContent() -> ConSub5ContentPresentation {
        buildLocalizedContent()
    }
    #endif
}
