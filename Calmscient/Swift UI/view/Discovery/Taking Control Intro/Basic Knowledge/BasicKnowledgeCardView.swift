//
//  BasicKnowledgeCardView.swift
//  Calmscient
//
//  Single Basic Knowledge list card (parity with `CustomCheckboxCell`).
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct BasicKnowledgeCardView: View {

    let title: String
    let showsCompletionCheckmark: Bool
    let onTap: () -> Void

    private let titlePurple = Color(red: 0.431, green: 0.419, blue: 0.702)

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 12) {
                Text(title)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 18))
                    .foregroundStyle(titlePurple)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if showsCompletionCheckmark {
                    Image("check")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.gray.opacity(0.5), radius: 2, x: 2, y: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Basic knowledge card — completed") {
    BasicKnowledgeCardView(
        title: "What's a 'standard drink'?",
        showsCompletionCheckmark: true,
        onTap: {}
    )
    .padding(.horizontal, 20)
}

@available(iOS 16.0, *)
#Preview("Basic knowledge card — incomplete") {
    BasicKnowledgeCardView(
        title: "What are the consequences?",
        showsCompletionCheckmark: false,
        onTap: {}
    )
    .padding(.horizontal, 20)
}
#endif
