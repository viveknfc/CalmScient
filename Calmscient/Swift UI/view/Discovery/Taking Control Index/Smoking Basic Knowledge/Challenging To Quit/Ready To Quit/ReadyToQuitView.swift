//
//  ReadyToQuitView.swift
//  Calmscient
//
//  SwiftUI ready-to-quit screen (parity with legacy `ReadyToQuitVC`).
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ReadyToQuitView: View {

    @ObservedObject var viewModel: ReadyToQuitViewModel

    private let pageBackground = Color(.systemBackground)

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    BasicStandardDrinkHeaderView(title: viewModel.content.headerTitle)

                    ForEach(Array(viewModel.content.bodyParagraphs.enumerated()), id: \.offset) { index, paragraph in
                        HoldYourLiquorBodyParagraphView(text: paragraph)
                            .padding(.bottom, index < viewModel.content.bodyParagraphs.count - 1 ? 10 : 0)
                    }

                    ConsequenceTopicsListView(
                        rows: viewModel.content.topicRows,
                        onTopicTap: viewModel.openTopic
                    )
                    .padding(.top, 10)
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
#Preview("Ready to quit") {
    let viewModel = ReadyToQuitViewModel()
    viewModel.applyPreviewState()
    return ReadyToQuitView(viewModel: viewModel)
}
#endif
