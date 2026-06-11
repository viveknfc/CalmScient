//
//  DayFeedbackQuestionTitle.swift
//  Calmscient
//
//  Section titles for day feedback cards.
//
//  Vivek
//  14 May 2026
//
import SwiftUI
@available(iOS 16.0, *)
struct DayFeedbackRequiredQuestionTitle: View {
    let plainText: String

    var body: some View {
        Text(plainText)
            .font(LoginDesignSystem.Typography.lexendMedium(size: 16))
            .foregroundStyle(LoginDesignSystem.ColorName.titleGray)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Question Title") {
    DayFeedbackRequiredQuestionTitle(plainText: "How is your focus / mental clarity?")
        .padding()
        .background(Color.white)
}
#endif
