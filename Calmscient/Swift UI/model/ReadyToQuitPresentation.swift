//
//  ReadyToQuitPresentation.swift
//  Calmscient
//
//  Localized content for the ready-to-quit screen (parity with `ReadyToQuitVC`).
//
//  Vivek
//  26 May 2026
//

import Foundation

struct ReadyToQuitContentPresentation: Equatable {
    let headerTitle: String
    let bodyParagraphs: [String]
    let topicRows: [ConsequenceTopicRowPresentation]
}

enum ReadyToQuitPresentation {

    private static let bodyParagraphKeys = [
        "ready_to_quit_body_paragraph_1",
        "ready_to_quit_body_paragraph_2",
    ]

    private static let topicDefinitions: [(id: Int, titleKey: String, topic: QuitSymptomTopic?)] = [
        (1, "Nicotine cravings", .nicotineCravings),
        (2, "Irritability and mood swings", .irritability),
        (3, "Difficulty concentrating", .difficultyConcentrating),
        (4, "Increased appetite and weight gain", .increasedAppetite),
        (5, "Sleep disturbances", .sleepDisturbances),
        (6, "Depression and anxiety", .depressionAnxiety),
        (7, "Feeling jumpy or restless", .feelingJumpy),
    ]

    static func buildLocalizedContent() -> ReadyToQuitContentPresentation {
        ReadyToQuitContentPresentation(
            headerTitle: "ready_to_quit_header".localized,
            bodyParagraphs: bodyParagraphKeys.map { $0.localized },
            topicRows: topicDefinitions.map { definition in
                ConsequenceTopicRowPresentation(
                    id: definition.id,
                    title: definition.titleKey.localized,
                    quitSymptomTopic: definition.topic
                )
            }
        )
    }

    #if DEBUG
    static func previewContent() -> ReadyToQuitContentPresentation {
        buildLocalizedContent()
    }
    #endif
}
