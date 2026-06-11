//
//  BasicKnowledgeVideoView.swift
//  Calmscient
//
//  SwiftUI brain video education screen (parity with legacy `BasicknowledgeVideo`).
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct BasicKnowledgeVideoView: View {

    @ObservedObject var viewModel: BasicKnowledgeVideoViewModel

    private let pageBackground = Color(uiColor: .systemBackground)

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    BasicKnowledgeVideoHeaderView(
                        questionTitle: viewModel.questionTitle,
                        brandTitle: viewModel.videoBrandTitle,
                        subtitle: viewModel.videoSubtitle
                    )
                    .padding(.top, 8)

                    BasicKnowledgeVideoPlayerSectionView(viewModel: viewModel)

                    BasicKnowledgeVideoBodyTextView(text: viewModel.bodyText)
                        .padding(.top, 16)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 88)
            }

            BreathingTechniqueType1CompleteButtonView(
                title: viewModel.completeButtonTitle,
                isEnabled: viewModel.isCompleteEnabled,
                action: viewModel.completeTapped
            )
            .padding(.bottom, 20)
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
#Preview("Brain video screen") {
    let viewModel = BasicKnowledgeVideoViewModel()
    viewModel.applyPreviewState()
    return BasicKnowledgeVideoView(viewModel: viewModel)
}
#endif
