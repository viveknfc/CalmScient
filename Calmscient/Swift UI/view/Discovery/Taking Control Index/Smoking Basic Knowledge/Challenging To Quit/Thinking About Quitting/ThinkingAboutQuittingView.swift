//
//  ThinkingAboutQuittingView.swift
//  Calmscient
//
//  SwiftUI thinking-about-quitting screen (parity with legacy `ThinkingAbtQuitingVC`).
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ThinkingAboutQuittingView: View {

    @ObservedObject var viewModel: ThinkingAboutQuittingViewModel

    private let pageBackground = Color(.systemBackground)

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    BasicStandardDrinkHeaderView(title: viewModel.content.headerTitle)
                        .padding(.bottom, 20)

                    ForEach(Array(viewModel.content.bodyParagraphs.enumerated()), id: \.offset) { index, paragraph in
                        HoldYourLiquorBodyParagraphView(text: paragraph)
                            .padding(.bottom, index < viewModel.content.bodyParagraphs.count - 1 ? 10 : 0)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 88)
            }

            BasicKnowledgeCompleteButtonView(
                title: viewModel.completeButtonTitle,
                onTap: viewModel.completeTapped
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(pageBackground.ignoresSafeArea())
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Thinking about quitting") {
    let viewModel = ThinkingAboutQuittingViewModel()
    viewModel.applyPreviewState()
    return ThinkingAboutQuittingView(viewModel: viewModel)
}
#endif
