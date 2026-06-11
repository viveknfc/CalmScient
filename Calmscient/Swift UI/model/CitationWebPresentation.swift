//
//  CitationWebPresentation.swift
//  Calmscient
//
//  Presentation model for sources and citations web content.
//
//  Vivek
//  19 May 2026
//

import Foundation

struct CitationWebPresentation: Equatable {
    static let defaultSourcesURL = "https://calmscient.in/courses/sources-and-citations"

    let pageURL: String

    init(pageURL: String = CitationWebPresentation.defaultSourcesURL) {
        self.pageURL = pageURL
    }
}
