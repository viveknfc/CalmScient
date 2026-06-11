//
//  MindfulWalkingView.swift
//  Calmscient
//
//  SwiftUI mindful walking detail (parity with legacy `MindfulWalking`).
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MindfulWalkingView: View {

    @ObservedObject var viewModel: MindfulWalkingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                MindfulWalkingHeaderView(
                    questionTitle: viewModel.questionTitle,
                    heroImageName: MindfulWalkingPresentation.heroImageName,
                    favoriteImageName: viewModel.favoriteImageName,
                    onFavoriteTap: viewModel.toggleFavorite
                )

                ProgressiveEqualizerView(
                    imageName: MindfulWalkingPresentation.equalizerImageName,
                    progress: viewModel.progress
                )
                .padding(.top, 30)
                .padding(.horizontal, 30)

                ProgressiveAudioControlsView(
                    rewindImageName: MindfulWalkingPresentation.rewindImageName,
                    playPauseImageName: viewModel.playPauseImageName,
                    forwardImageName: MindfulWalkingPresentation.forwardImageName,
                    isPlayerReady: viewModel.isPlayerReady,
                    onRewind: viewModel.seekBackwardTenSeconds,
                    onPlayPause: viewModel.togglePlayPause,
                    onForward: viewModel.seekForwardTenSeconds
                )
                .padding(.top, 30)

                MindfulWalkingBenefitsListView(benefits: viewModel.benefits)
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                    .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 90)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) {
            ProgressiveCompleteButtonView(
                title: viewModel.completeButtonTitle,
                isEnabled: viewModel.isCompleteEnabled,
                action: viewModel.completeTapped
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground).ignoresSafeArea())
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Mindful walking") {
    let viewModel = MindfulWalkingViewModel()
    viewModel.applyPreviewState(isPlaying: false, progress: 0.35, isCompleteEnabled: false, isFavorited: false)
    return MindfulWalkingView(viewModel: viewModel)
}
#endif
