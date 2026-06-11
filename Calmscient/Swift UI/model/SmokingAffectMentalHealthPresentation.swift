//
//  SmokingAffectMentalHealthPresentation.swift
//  Calmscient
//
//  Localized content for the smoking and mental health basic knowledge screen.
//
//  Vivek
//  26 May 2026
//

import Foundation

enum SmokingAffectMentalHealthPresentation {

    private static let bodyParagraphKeys = [
        "smoking_mental_health_body_paragraph_1",
        "smoking_mental_health_body_paragraph_2",
        "smoking_mental_health_body_paragraph_3",
        "smoking_mental_health_body_paragraph_4",
    ]

    static func buildLocalizedContent() -> SmokingEducationContentPresentation {
        SmokingEducationContentPresentation(
            headerTitle: "smoking_mental_health_header".localized,
            bodyParagraphs: bodyParagraphKeys.map { $0.localized }
        )
    }
}
