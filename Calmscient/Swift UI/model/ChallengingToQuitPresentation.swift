//
//  ChallengingToQuitPresentation.swift
//  Calmscient
//
//  Localized content for the challenging-to-quit index (parity with `ChallengingtoQuitVC`).
//
//  Vivek
//  26 May 2026
//

import Foundation

struct ChallengingToQuitContentPresentation: Equatable {
    let headerTitle: String
    let bodyParagraphs: [String]
    let topicRows: [ConsequenceTopicRowPresentation]
}

enum ChallengingToQuitPresentation {

    private static let bodyParagraphKeys = [
        "challenging_to_quit_body_paragraph_1",
        "challenging_to_quit_body_paragraph_2",
    ]

    private static let topicDefinitions: [(id: Int, titleKey: String, storyboardIdentifier: String)] = [
        (1, "challenging_to_quit_topic_thinking", "ThinkingAbtQuitingVC"),
        (2, "challenging_to_quit_topic_ready", "ReadyToQuitVC"),
        (3, "challenging_to_quit_topic_quitting", "TryingToQuitVC"),
        (4, "challenging_to_quit_topic_smoke_free", "TobaccoFreeVC"),
    ]

    static func buildLocalizedContent() -> ChallengingToQuitContentPresentation {
        ChallengingToQuitContentPresentation(
            headerTitle: "challenging_to_quit_header".localized,
            bodyParagraphs: bodyParagraphKeys.map { $0.localized },
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
    static func previewContent() -> ChallengingToQuitContentPresentation {
        buildLocalizedContent()
    }
    #endif
}
