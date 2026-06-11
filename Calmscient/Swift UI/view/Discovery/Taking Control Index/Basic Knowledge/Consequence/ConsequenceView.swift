//
//  ConsequenceView.swift
//  Calmscient
//
//  SwiftUI consequences index screen (parity with legacy `ConsequenceVC`).
//
//  Vivek
//  25 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ConsequenceView: View {

    @ObservedObject var viewModel: ConsequenceViewModel

    private let pageBackground = Color(.systemBackground)

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    BasicStandardDrinkHeaderView(title: viewModel.content.headerTitle)

                    ConsequenceIntroBodyTextView(text: viewModel.content.introBodyText)

                    ConsequenceSeeSomeLineView(text: viewModel.content.seeSomeLineText)
                        .padding(.top, 0)

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
        .overlay {
            if viewModel.isCompleting {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Consequences index") {
    let viewModel = ConsequenceViewModel()
    viewModel.applyPreviewState()
    return ConsequenceView(viewModel: viewModel)
}
#endif
