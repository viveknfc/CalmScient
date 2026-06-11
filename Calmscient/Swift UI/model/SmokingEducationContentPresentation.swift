//
//  SmokingEducationContentPresentation.swift
//  Calmscient
//
//  Shared content model for smoking basic knowledge article screens.
//
//  Vivek
//  26 May 2026
//

import Foundation

struct SmokingEducationContentPresentation: Equatable {
    let headerTitle: String
    let bodyParagraphs: [String]
    let referenceURL: String?

    init(headerTitle: String, bodyParagraphs: [String], referenceURL: String? = nil) {
        self.headerTitle = headerTitle
        self.bodyParagraphs = bodyParagraphs
        self.referenceURL = referenceURL
    }
}
