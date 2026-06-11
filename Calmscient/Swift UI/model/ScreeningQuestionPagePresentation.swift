//
//  ScreeningQuestionPagePresentation.swift
//  Calmscient
//
//  Option row models for the screening questionnaire pager.
//
//  Vivek
//  15 May 2026
//

import Foundation

@available(iOS 16.0, *)
struct ScreeningQuestionOptionPresentation: Identifiable {
    let id: String
    let label: String
    let index: Int
    let isSelected: Bool
}

#if DEBUG
@available(iOS 16.0, *)
enum ScreeningQuestionPagePresentationPreviewData {
    static func sampleQuestionnaire() -> [QuestionnaireItem] {
        let json = """
        {
          "statusResponse": { "responseCode": 200, "responseMessage": "OK" },
          "questionnaire": [
            {
              "questionNo": 1,
              "questionId": 1,
              "questionName": "1. Little interest or pleasure in doing things.",
              "optionTypeId": "1",
              "optionType": "radio",
              "answerResponse": [
                { "optionLabelId": 1, "optionLabel": "Not at all", "optionScore": "0", "answer": null, "answerId": null, "selected": "N" },
                { "optionLabelId": 2, "optionLabel": "Several days", "optionScore": "1", "answer": null, "answerId": null, "selected": "N" },
                { "optionLabelId": 3, "optionLabel": "More than half of the days", "optionScore": "2", "answer": null, "answerId": null, "selected": "N" },
                { "optionLabelId": 4, "optionLabel": "Nearly everyday", "optionScore": "3", "answer": null, "answerId": null, "selected": "N" }
              ]
            }
          ]
        }
        """
        guard let data = json.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(QuestionnaireResponse.self, from: data) else {
            return []
        }
        return decoded.questionnaire
    }
}
#endif
