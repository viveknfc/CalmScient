//
//  BasicKnowledgeView.swift
//  Calmscient
//
//  SwiftUI Basic Knowledge index list (parity with legacy `Basicknowledge`).
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct BasicKnowledgeView: View {

    @ObservedObject var viewModel: BasicKnowledgeViewModel

    private let pageBackground = Color(white: 0.98)

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVStack(spacing: 10) {
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
#Preview("Basic knowledge list") {
    let viewModel = BasicKnowledgeViewModel()
    viewModel.applyPreviewState(rows: BasicKnowledgeRowPresentation.previewRows())
    return BasicKnowledgeView(viewModel: viewModel)
}
#endif
