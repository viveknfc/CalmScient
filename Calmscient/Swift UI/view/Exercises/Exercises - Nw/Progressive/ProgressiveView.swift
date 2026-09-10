//
//  ProgressiveView.swift
//  Calmscient
//
//  SwiftUI progressive muscle relaxation detail (parity with legacy `Progressive`).
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ProgressiveView: View {

    @ObservedObject var viewModel: ProgressiveViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ProgressiveHeaderView(
                    heroImageName: ProgressivePresentation.heroImageName,
                    favoriteImageName: viewModel.favoriteImageName,
                    onFavoriteTap: viewModel.toggleFavorite
                )

                if viewModel.isAudioComingSoon {
                    Text(viewModel.comingSoonTitle)
                        .font(.system(size: 20, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                        .padding(.horizontal, 30)
                } else {
                    ProgressiveEqualizerView(
                        imageName: ProgressivePresentation.equalizerImageName,
                        progress: viewModel.progress
                    )
                    .padding(.top, 45)
                    .padding(.horizontal, 30)

                    ProgressiveAudioControlsView(
                        rewindImageName: ProgressivePresentation.rewindImageName,
                        playPauseImageName: viewModel.playPauseImageName,
                        forwardImageName: ProgressivePresentation.forwardImageName,
                        isPlayerReady: viewModel.isPlayerReady,
                        onRewind: viewModel.seekBackwardTenSeconds,
                        onPlayPause: viewModel.togglePlayPause,
                        onForward: viewModel.seekForwardTenSeconds
                    )
                    .padding(.top, 37)
                }

                Spacer(minLength: 220)

                ProgressiveCompleteButtonView(
                    title: viewModel.completeButtonTitle,
                    isEnabled: viewModel.isCompleteEnabled,
                    action: viewModel.completeTapped
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground).ignoresSafeArea())
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Progressive") {
    let viewModel = ProgressiveViewModel()
    viewModel.applyPreviewState(isPlaying: false, progress: 0.4, isCompleteEnabled: false, isFavorited: false)
    return ProgressiveView(viewModel: viewModel)
}
#endif
