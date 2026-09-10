//
//  ScreeningQuestionsView.swift
//  Calmscient
//
//  SwiftUI screening questionnaire pager (parity with legacy `ScreeningQuestionsViewController`).
//
//  Vivek
//  15 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ScreeningQuestionsView: View {

    @ObservedObject var viewModel: ScreeningQuestionsViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("AppBackGroundColor")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if !viewModel.currentQuestionText.isEmpty {
                            ScreeningQuestionsQuestionHeaderView(
                                questionText: viewModel.currentQuestionText
                            )
                            .padding(.horizontal, 32)
                            .padding(.top, 30)
                        }

                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.currentOptions) { option in
                                ScreeningQuestionsOptionRowView(option: option) {
                                    viewModel.selectOption(at: option.index)
                                }
                            }
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 32)
                        .id(viewModel.pageNumber)
                        .transition(.opacity)
                    }
                    .padding(.bottom, 80)
                    .animation(.easeInOut(duration: 0.35), value: viewModel.pageNumber)
                }
                .scrollIndicators(.hidden)
            }

            ScreeningQuestionsBottomBarView(viewModel: viewModel)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("PHQ-9 question") {
    let viewModel = ScreeningQuestionsViewModel()
    viewModel.applyPreviewState(
        questions: ScreeningQuestionPagePresentationPreviewData.sampleQuestionnaire()
    )
    return ScreeningQuestionsView(viewModel: viewModel)
}
#endif
