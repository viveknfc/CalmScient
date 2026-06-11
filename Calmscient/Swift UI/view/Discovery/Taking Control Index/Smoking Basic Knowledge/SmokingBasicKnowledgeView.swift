//
//  SmokingBasicKnowledgeView.swift
//  Calmscient
//
//  SwiftUI Smoking Basic Knowledge index list (parity with legacy `SmokingBasicVc`).
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct SmokingBasicKnowledgeView: View {

    @ObservedObject var viewModel: SmokingBasicKnowledgeViewModel

    private let pageBackground = Color(white: 0.98)

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(viewModel.rows) { row in
                        BasicKnowledgeCardView(
                            title: row.title,
                            showsCompletionCheckmark: row.showsCompletionCheckmark,
                            onTap: { viewModel.openRow(row) }
                        )
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
        .overlay {
            if viewModel.isLoading {
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
#Preview("Smoking basic knowledge list") {
    let viewModel = SmokingBasicKnowledgeViewModel()
    viewModel.applyPreviewState(rows: BasicKnowledgeRowPresentation.previewSmokingRows())
    return SmokingBasicKnowledgeView(viewModel: viewModel)
}
#endif
