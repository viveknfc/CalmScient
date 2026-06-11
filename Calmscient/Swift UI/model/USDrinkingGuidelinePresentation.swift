//
//  USDrinkingGuidelinePresentation.swift
//  Calmscient
//
//  Section and card models for the U.S. drinking guidelines screen.
//
//  Vivek
//  21 May 2026
//

import Foundation

struct USDrinkingGuidelineCardPresentation: Identifiable, Equatable {
    let id: String
    let genderLabel: String
    let detailLines: [String]
}

struct USDrinkingGuidelineSectionPresentation: Identifiable, Equatable {
    let id: String
    let title: String?
    let titlePrefix: String?
    let titleAccent: String?
    let subtitle: String?
    let cards: [USDrinkingGuidelineCardPresentation]

    static func previewSections() -> [USDrinkingGuidelineSectionPresentation] {
        USGuideLineForDrinkingPresentationBuilder.buildSections(
            usGuidelinesTitle: "What are the U.S. guidelines for drinking?",
            dietarySubtitle: "The 2020–2025 Dietary Guidelines recommend:",
            menLabel: "Men",
            womenLabel: "Women",
            menStandard: "Up to 2 drinks per day",
            womenStandard: "Up to 1 drink per day",
            whatIsPrefix: "What is",
            alcoholMisuseAccent: "alcohol misuse?",
            niaaaHeavySubtitle: "NIAAA defines heavy drinking as follows:",
            menHeavyLine1: "Up to 5 or more drinks on",
            menHeavyLine2: "any day or 15 drinks or more per week",
            womenHeavyLine1: "Up to 4 or more drinks on",
            womenHeavyLine2: "any day or 8 drinks or more per week",
            bingeAccent: "binge drinking?",
            niaaaBingeSubtitle: "NIAAA defines it as follows",
            menBingeLine1: "Up to 5 or more drinks",
            menBingeLine2: "within about 2 hours",
            womenBingeLine1: "Up to 4 or more drinks",
            womenBingeLine2: "within about 2 hours"
        )
    }
}

enum USGuideLineForDrinkingPresentationBuilder {

    static func buildSections(
        usGuidelinesTitle: String,
        dietarySubtitle: String,
        menLabel: String,
        womenLabel: String,
        menStandard: String,
        womenStandard: String,
        whatIsPrefix: String,
        alcoholMisuseAccent: String,
        niaaaHeavySubtitle: String,
        menHeavyLine1: String,
        menHeavyLine2: String,
        womenHeavyLine1: String,
        womenHeavyLine2: String,
        bingeAccent: String,
        niaaaBingeSubtitle: String,
        menBingeLine1: String,
        menBingeLine2: String,
        womenBingeLine1: String,
        womenBingeLine2: String
    ) -> [USDrinkingGuidelineSectionPresentation] {
        [
            USDrinkingGuidelineSectionPresentation(
                id: "standard",
                title: usGuidelinesTitle,
                titlePrefix: nil,
                titleAccent: nil,
                subtitle: dietarySubtitle,
                cards: [
                    USDrinkingGuidelineCardPresentation(
                        id: "standard-men",
                        genderLabel: menLabel,
                        detailLines: [menStandard]
                    ),
                    USDrinkingGuidelineCardPresentation(
                        id: "standard-women",
                        genderLabel: womenLabel,
                        detailLines: [womenStandard]
                    ),
                ]
            ),
            USDrinkingGuidelineSectionPresentation(
                id: "heavy",
                title: nil,
                titlePrefix: whatIsPrefix,
                titleAccent: alcoholMisuseAccent,
                subtitle: niaaaHeavySubtitle,
                cards: [
                    USDrinkingGuidelineCardPresentation(
                        id: "heavy-men",
                        genderLabel: menLabel,
                        detailLines: [menHeavyLine1, menHeavyLine2]
                    ),
                    USDrinkingGuidelineCardPresentation(
                        id: "heavy-women",
                        genderLabel: womenLabel,
                        detailLines: [womenHeavyLine1, womenHeavyLine2]
                    ),
                ]
            ),
            USDrinkingGuidelineSectionPresentation(
                id: "binge",
                title: nil,
                titlePrefix: whatIsPrefix,
                titleAccent: bingeAccent,
                subtitle: niaaaBingeSubtitle,
                cards: [
                    USDrinkingGuidelineCardPresentation(
                        id: "binge-men",
                        genderLabel: menLabel,
                        detailLines: [menBingeLine1, menBingeLine2]
                    ),
                    USDrinkingGuidelineCardPresentation(
                        id: "binge-women",
                        genderLabel: womenLabel,
                        detailLines: [womenBingeLine1, womenBingeLine2]
                    ),
                ]
            ),
        ]
    }
}
