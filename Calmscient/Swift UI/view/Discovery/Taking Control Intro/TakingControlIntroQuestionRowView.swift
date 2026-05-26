//
//  TakingControlIntroQuestionRowView.swift
//  Calmscient
//
//  Single CAGE-AID question with Yes / No choices.
//
//  Vivek
//  19 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TakingControlIntroQuestionRowView: View {

    let row: TakingControlIntroQuestionRowPresentation
    let yesTitle: String
    let noTitle: String
    let onSelectYes: () -> Void
    let onSelectNo: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            questionLabel

            VStack(spacing: 2) {
                TakingControlIntroChoiceButton(
                    title: yesTitle,
                    isSelected: row.selectedAnswer == .yes,
                    action: onSelectYes
                )
                TakingControlIntroChoiceButton(
                    title: noTitle,
                    isSelected: row.selectedAnswer == .no,
                    action: onSelectNo
                )
            }
        }
        .padding(.vertical, 8)
    }

    private var questionLabel: some View {
        Text(row.questionText)
            .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
            .foregroundStyle(Color.primary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Question row") {
    TakingControlIntroQuestionRowView(
        row: TakingControlIntroPreviewData.sampleQuestions()[0],
        yesTitle: "Yes",
        noTitle: "No",
        onSelectYes: {},
        onSelectNo: {}
    )
    .padding()
}
#endif
