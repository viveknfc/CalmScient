//
//  SmokingRelaxView.swift
//  Calmscient
//
//  SwiftUI smoking relax education screen (parity with legacy `SmokingRelaxVC`).
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct SmokingRelaxView: View {

    @ObservedObject var viewModel: SmokingRelaxViewModel

    private let pageBackground = Color("AppBackGroundColor")

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
#Preview("Smoking relax screen") {
    let viewModel = SmokingRelaxViewModel()
    viewModel.applyPreviewState()
    return SmokingRelaxView(viewModel: viewModel)
}
#endif
