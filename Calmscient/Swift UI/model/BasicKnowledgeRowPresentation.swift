//
//  BasicKnowledgeRowPresentation.swift
//  Calmscient
//
//  Row model for the Basic Knowledge index list (parity with `Basicknowledge` API `index`).
//
//  Vivek
//  21 May 2026
//

import Foundation

struct BasicKnowledgeRowPresentation: Identifiable, Equatable {
    let id: Int
    let sectionId: Int
    let title: String
    let showsCompletionCheckmark: Bool
    let listIndex: Int

    static func rows(from indexArray: [[String: Any]]) -> [BasicKnowledgeRowPresentation] {
        indexArray.enumerated().compactMap { offset, item in
            guard let sectionId = item["sectionId"] as? Int,
                  let title = item["sectionName"] as? String else {
                return nil
            }
            let isCompleted = (item["isCompleted"] as? Int) == 1
            return BasicKnowledgeRowPresentation(
                id: sectionId,
                sectionId: sectionId,
                title: title,
                showsCompletionCheckmark: isCompleted,
                listIndex: offset
            )
        }
    }

    #if DEBUG
    static func previewSmokingRows() -> [BasicKnowledgeRowPresentation] {
        [
            BasicKnowledgeRowPresentation(
                id: 1,
                sectionId: 1,
                title: "Tobacco",
                showsCompletionCheckmark: true,
                listIndex: 0
            ),
            BasicKnowledgeRowPresentation(
                id: 2,
                sectionId: 2,
                title: "Vaping",
                showsCompletionCheckmark: false,
                listIndex: 1
            ),
            BasicKnowledgeRowPresentation(
                id: 3,
                sectionId: 3,
                title: "Relaxation and smoking",
                showsCompletionCheckmark: false,
                listIndex: 2
            ),
            BasicKnowledgeRowPresentation(
                id: 4,
                sectionId: 4,
                title: "Challenging to quit",
                showsCompletionCheckmark: false,
                listIndex: 3
            ),
            BasicKnowledgeRowPresentation(
                id: 5,
                sectionId: 5,
                title: "Smoking and mental health",
                showsCompletionCheckmark: true,
                listIndex: 4
            ),
            BasicKnowledgeRowPresentation(
                id: 6,
                sectionId: 6,
                title: "My smoking habit",
                showsCompletionCheckmark: false,
                listIndex: 5
            ),
        ]
    }

    static func previewRows() -> [BasicKnowledgeRowPresentation] {
        [
            BasicKnowledgeRowPresentation(
                id: 1,
                sectionId: 1,
                title: "What's a 'standard drink'?",
                showsCompletionCheckmark: true,
                listIndex: 0
            ),
            BasicKnowledgeRowPresentation(
                id: 2,
                sectionId: 2,
                title: "What are the U.S. guidelines for drink?",
                showsCompletionCheckmark: false,
                listIndex: 1
            ),
            BasicKnowledgeRowPresentation(
                id: 3,
                sectionId: 3,
                title: "When is drink in moderation too much?",
                showsCompletionCheckmark: false,
                listIndex: 2
            ),
            BasicKnowledgeRowPresentation(
                id: 4,
                sectionId: 4,
                title: "What happens to your brain when you drink?",
                showsCompletionCheckmark: false,
                listIndex: 3
            ),
            BasicKnowledgeRowPresentation(
                id: 5,
                sectionId: 5,
                title: "What are the consequences?",
                showsCompletionCheckmark: true,
                listIndex: 4
            ),
            BasicKnowledgeRowPresentation(
                id: 6,
                sectionId: 6,
                title: "Why is the ability to hold your liquor a concern?",
                showsCompletionCheckmark: false,
                listIndex: 5
            ),
            BasicKnowledgeRowPresentation(
                id: 7,
                sectionId: 7,
                title: "My drinking habit",
                showsCompletionCheckmark: false,
                listIndex: 6
            ),
        ]
    }
    #endif
}
