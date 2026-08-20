//
//  TakingControlIntroSecondView.swift
//  Calmscient
//
//  SwiftUI follow-up test selection after CAGE-AID (parity with `IntroSecondPageVC`).
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TakingControlIntroSecondView: View {

    @ObservedObject var viewModel: TakingControlIntroSecondViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("AppBackGroundColor")
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TakingControlIntroSecondInstructionView(text: viewModel.instructionText)
                        .padding(.top, 8)

                    TakingControlIntroSecondTestCardView(
                        title: viewModel.auditTitle,
                        subtitle: viewModel.auditSubtitle,
                        onTap: { viewModel.openAuditFlow() }
                    )
                    .padding(.top, 20)

                    TakingControlIntroSecondTestCardView(
                        title: viewModel.dastTitle,
                        subtitle: viewModel.dastSubtitle,
                        onTap: { viewModel.openDastFlow() }
                    )
                }
                .padding(.top, 30)
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)

            TakingControlIntroSecondPagerButtonsView(
                onPrevious: { viewModel.openPreviousIntroPage() },
                onNext: { viewModel.openNextPage() }
            )
            .padding(.bottom, 8)

            // Loading is shown by the app-wide toast activity indicator that the view model
            // drives (`showToastActivity` / `hideToastActivity`). A second SwiftUI
            // `ProgressView` overlay here would render a differently styled spinner on top
            // of it, so it is intentionally not used.
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Intro second — full page") {
    let viewModel = TakingControlIntroSecondViewModel()
    viewModel.applyPreviewState()
    return TakingControlIntroSecondView(viewModel: viewModel)
}
#endif
