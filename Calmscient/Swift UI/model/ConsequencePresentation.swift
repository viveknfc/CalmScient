//
//  ConsequencePresentation.swift
//  Calmscient
//
//  Content models for the consequences index screen (parity with `ConsequenceVC`).
//
//  Vivek
//  25 May 2026
//

import Foundation

struct ConsequenceContentPresentation: Equatable {
    let headerTitle: String
    let introBodyText: String
    let seeSomeLineText: String
    let topicRows: [ConsequenceTopicRowPresentation]
}

struct ConsequenceTopicRowPresentation: Identifiable, Equatable {
    let id: Int
    let title: String
    let storyboardIdentifier: String
    let quitSymptomTopic: QuitSymptomTopic?

    init(
        id: Int,
        title: String,
        storyboardIdentifier: String = "",
        quitSymptomTopic: QuitSymptomTopic? = nil
    ) {
        self.id = id
        self.title = title
        self.storyboardIdentifier = storyboardIdentifier
        self.quitSymptomTopic = quitSymptomTopic
    }
}

enum ConsequencePresentation {

    private static let topicDefinitions: [(id: Int, titleKey: String, storyboardIdentifier: String)] = [
        (1, "Fatalities and injuries", "ConSub1VC"),
        (2, "Alcohol-related mental dysfunction", "ConSub2VC"),
        (3, "Alcohol-related blackouts", "ConSub3VC"),
        (4, "Health problems", "ConSub4VC"),
        (5, "Alcohol use disorder (AUD)", "ConSub5VC"),
    ]

    static func buildLocalizedContent() -> ConsequenceContentPresentation {
        ConsequenceContentPresentation(
            headerTitle: "What are the consequence?".localized,
            introBodyText: "consequences_intro_body".localized,
            seeSomeLineText: "consequences_intro_see_some".localized,
            topicRows: topicDefinitions.map { definition in
                ConsequenceTopicRowPresentation(
                    id: definition.id,
                    title: definition.titleKey.localized,
                    storyboardIdentifier: definition.storyboardIdentifier
                )
            }
        )
    }

    #if DEBUG
    static func previewContent() -> ConsequenceContentPresentation {
        buildLocalizedContent()
    }
    #endif
}
