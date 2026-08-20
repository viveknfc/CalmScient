//
//  TakingControlIntroView.swift
//  Calmscient
//
//  SwiftUI CAGE-AID intro questionnaire (parity with `VTakingControlIntroVC`).
//
//  Vivek
//  19 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TakingControlIntroView: View {

    @ObservedObject var viewModel: TakingControlIntroViewModel

    var body: some View {
        ZStack {
            Color("AppBackGroundColor")
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    TakingControlIntroHeaderView(introText: viewModel.introAttributedText)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                    VStack(spacing: 10) {
                        ForEach(viewModel.questionRows) { row in
                            TakingControlIntroQuestionRowView(
                                row: row,
                                yesTitle: viewModel.yesButtonTitle,
                                noTitle: viewModel.noButtonTitle,
                                onSelectYes: { viewModel.selectAnswer(.yes, forQuestionAt: row.id) },
                                onSelectNo: { viewModel.selectAnswer(.no, forQuestionAt: row.id) }
                            )
                        }
                    }
                    .padding(20)

                    TakingControlIntroScoreView(
                        title: viewModel.yourPointsTitle,
                        score: viewModel.yesCount
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    TakingControlIntroInterpretationBannerView(text: viewModel.interpretationText)
                        .padding(.top, 30)

                    LoginGradientButton(title: viewModel.submitButtonTitle) {
                        viewModel.submitTapped()
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 24)
                }
            }
            .scrollIndicators(.hidden)

            // Loading is shown by the app-wide toast activity indicator that the view model
            // drives (`showToastActivity` / `hideToastActivity`). A second SwiftUI
            // `ProgressView` overlay here would render a differently styled spinner on top
            // of it, so it is intentionally not used.
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("CAGE-AID intro") {
    let viewModel = TakingControlIntroViewModel()
    viewModel.applyPreviewState(rows: TakingControlIntroPreviewData.sampleQuestions())
    return TakingControlIntroView(viewModel: viewModel)
}
#endif
