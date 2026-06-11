//
//  BasicKnowledgeVideoPresentation.swift
//  Calmscient
//
//  Static content and API identifiers for the Basic Knowledge brain video screen.
//
//  Vivek
//  21 May 2026
//

import Foundation

enum BasicKnowledgeVideoPresentation {

    /// Server title for favorites save/load (must match API / legacy `BasicknowledgeVideo`).
    static let favoriteAPITitle = "What happens to your brain when you drink?"

    static let favoritePageId = 1

    static var videoURLString: String {
        "BASIC_KNOWLEDGE_Brain_Video_URL".localized
    }
}
