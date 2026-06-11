//
//  ScreeningQuestionsQuestionHeaderView.swift
//  Calmscient
//
//  Question title for the current screening questionnaire page.
//
//  Vivek
//  15 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ScreeningQuestionsQuestionHeaderView: View {

    let questionText: String

    var body: some View {
        Text(questionText)
            .font(LoginDesignSystem.Typography.lexendMedium(size: 16))
            .foregroundStyle(Color("screeningQuestionsMainTitleColor"))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Question header") {
    ScreeningQuestionsQuestionHeaderView(
        questionText: "1. Little interest or pleasure in doing things."
    )
    .padding(.horizontal, 32)
}
#endif
