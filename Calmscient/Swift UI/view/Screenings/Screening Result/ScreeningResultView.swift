//
//  ScreeningResultView.swift
//  Calmscient
//
//  SwiftUI screening results screen (parity with legacy `ScreeningResultVC`).
//
//  Vivek
//  15 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ScreeningResultView: View {

    @ObservedObject var viewModel: ScreeningResultViewModel

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if let result = viewModel.result {
                    ScreeningResultReminderBannerView(
                        testDateText: result.testDateText,
                        testTimeText: result.testTimeText,
                        remindMeTitle: viewModel.remindMeTitle,
                        remindOptionTitle: viewModel.remindOptionTitle
                    )

                    ScreeningResultScoreCardView(
                        screeningName: result.screeningName,
                        score: result.score,
                        totalScore: result.totalScore,
                        progress: result.progress,
                        scoreMarkedTitle: viewModel.scoreMarkedTitle,
                        totalScoreTitle: viewModel.totalScoreTitle,
                        onInfoTap: { viewModel.presentMoreInfo() }
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 95)

                    Spacer(minLength: 16)

                    if PatientLanguagePreference.shouldShowNeedToTalkButton() {
                        LoginGradientButton(title: viewModel.needToTalkButtonTitle) {
                            viewModel.openNeedToTalk()
                        }
                        .padding(.bottom, 33)
                    }
                } else {
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white.ignoresSafeArea())
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Screening results") {
    let viewModel = ScreeningResultViewModel()
    if let result = ScreeningResultPresentationPreviewData.sample() {
        viewModel.applyPreviewState(result: result)
    }
    return ScreeningResultView(viewModel: viewModel)
}
#endif
