//
//  MindfulnessView.swift
//  Calmscient
//
//  SwiftUI mindfulness exercise detail (parity with legacy `MindfulNess`).
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MindfulnessView: View {

    @ObservedObject var viewModel: MindfulnessViewModel

    private var isDarkMode: Bool {
        (UserDefaults.standard.value(forKey: "isDarkMode") ?? false) as? Bool ?? false
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    MindfulnessStepProgressView(imageName: viewModel.step.progressImageName)
                        .padding(.top, 20)

                    MindfulnessBodyTextView(
                        content: viewModel.step.primaryText,
                        isDarkMode: isDarkMode
                    )
                    .padding(.top, 20)

                    if viewModel.step.secondaryText != .none {
                        MindfulnessBodyTextView(
                            content: viewModel.step.secondaryText,
                            isDarkMode: isDarkMode
                        )
                        .padding(.top, 20)
                    }

                    if viewModel.step.showsFavoriteToolbar {
                        MindfulnessFavoriteToolbarView(
                            favoriteImageName: viewModel.favoriteImageName,
                            onFavoriteTap: viewModel.toggleFavorite
                        )
                        .padding(.top, 8)
                    }

                    MindfulnessIllustrationView(
                        imageName: viewModel.step.illustrationImageName,
                        fit: viewModel.step.illustrationFit
                    )
                    .padding(.top, 10)
                    .padding(.bottom, 50)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 77)
            }
            .scrollIndicators(.hidden)

            MindfulnessBottomBarView(
                showsBack: viewModel.step.showsBackControl,
                showsForward: viewModel.step.showsForwardControl,
                showsComplete: viewModel.step.showsCompleteButton,
                completeTitle: viewModel.completeButtonTitle,
                onBack: viewModel.goToPreviousStep,
                onForward: viewModel.goToNextStep,
                onComplete: viewModel.completeTapped
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground).ignoresSafeArea())
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Mindfulness — step 1") {
    let viewModel = MindfulnessViewModel()
    viewModel.applyPreviewState(stepIndex: 0)
    return MindfulnessView(viewModel: viewModel)
}

@available(iOS 16.0, *)
#Preview("Mindfulness — final step") {
    let viewModel = MindfulnessViewModel()
    viewModel.applyPreviewState(stepIndex: 5)
    return MindfulnessView(viewModel: viewModel)
}
#endif
