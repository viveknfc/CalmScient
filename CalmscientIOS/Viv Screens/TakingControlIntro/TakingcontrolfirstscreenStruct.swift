//
//  TakingcontrolfirstscreenStruct.swift
//  CalmscientIOS
//
//  Created by NFC User on 14/05/25.
//

import Foundation

struct TakingIntrofirstScreenQuestions: Codable {
    let questionnaire: [Question]
}

struct Question: Codable {
    let questionId: Int
    let questionName: String
    let optionTypeId: String
    let answerResponse: [Answer]
}

struct Answer: Codable {
    let optionLabelId: Int
    let optionLabel: String
    let optionScore: String
    let answer: String?
    let answerId: Int?
    let selected: String

    var optionScoreInt: Int? {
        return Int(optionScore)
    }
}


struct TakingFirstQueSummary {
    let questionId: Int
    let questionName: String
    let optionTypeId: String

    var selectedanswerId: Int?
    var selectedScore: Int?
    var selectedoptionId: Int?
    var selectedAnswerLabel: String?
}

