//
//  ConSub1Presentation.swift
//  Calmscient
//
//  Content models for Fatalities and injuries (parity with `ConSub1VC`).
//
//  Vivek
//  25 May 2026
//

import Foundation

struct ConSub1ContentPresentation: Equatable {
    let headerTitle: String
    let introText: String
    let factorIntroText: String
    let bulletItems: [String]
}

struct ConSub1AlertPresentation: Equatable {
    let title: String
    let bodyText: String
}

enum ConSub1Presentation {

    private static let bulletItemKeys = [
        "DRINKING_CONTROL_Thirty_percent_Of_Suicides",
        "DRINKING_CONTROL_Forty_Of_Fatal_Burn_Injuries",
        "DRINKING_CONTROL_Fifty_Of_Fatal_Drownings_And_Of_Homicides_And_About_Message",
        "DRINKING_CONTROL_Thirtyone_Percent_Fatal_Crashes",
        "DRINKING_CONTROL_Significant_Number_Of_Sexual_Assaults",
    ]

    static func buildLocalizedContent() -> ConSub1ContentPresentation {
        ConSub1ContentPresentation(
            headerTitle: "Fatalities and injuries".localized,
            introText: "DRINKING_CONTROL_Consequence_Sub1_Intro".localized,
            factorIntroText: "DRINKING_CONTROL_Consequence_Sub1_Factor_Intro".localized,
            bulletItems: bulletItemKeys.map { $0.localized }
        )
    }

    static func buildLocalizedAlert() -> ConSub1AlertPresentation {
        ConSub1AlertPresentation(
            title: "DRINKING_CONTROL_ALERT_DUI_TITLE".localized,
            bodyText: "DRINKING_CONTROL_ALERT_DUI_BODY".localized
        )
    }

    #if DEBUG
    static func previewContent() -> ConSub1ContentPresentation {
        buildLocalizedContent()
    }

    static func previewAlert() -> ConSub1AlertPresentation {
        buildLocalizedAlert()
    }
    #endif
}
