//
//  BreathingExerciseVideoSectionView.swift
//  Calmscient
//
//  Video intro, player controls, and progress for breathing exercise detail screens.
//
//  Vivek
//  21 May 2026
//

import AVFoundation
import SwiftUI

@available(iOS 16.0, *)
struct BreathingExerciseVideoSectionView<VM: BreathingExerciseVideoViewModel>: View {

    @ObservedObject var viewModel: VM

    private let textColor = Color("lineChartLabelColor")
    private let videoCornerRadius: CGFloat = 10

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.videoIntroText)
                .font(LoginDesignSystem.Typography.lexendLight(size: 15))
                .foregroundStyle(textColor)
                .fixedSize(horizontal: false, vertical: true)

            if let player = viewModel.player {
                videoSurface(player: player)
            }
        }
    }

    @ViewBuilder
    private func videoSurface(player: AVPlayer) -> some View {
        ZStack {
            BreathingTechniqueType1VideoPlayerRepresentable(player: player)
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: videoCornerRadius, style: .continuous))

            if viewModel.showsThumbnail {
                Image("thumbnail")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 220)
                    .clipShape(RoundedRectangle(cornerRadius: videoCornerRadius, style: .continuous))
                    .allowsHitTesting(false)
            }

            VStack {
                HStack {
                    Spacer()
                    favoriteButton
                }
                .padding(12)

                Spacer()

                playbackControls

                Spacer()

                progressSlider
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    fullscreenButton
                }
                .padding(12)
            }
        }
        .frame(height: 200)
        .background(
            LinearGradient(
                colors: [Color(hex: "#D8EEF8"), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: videoCornerRadius, style: .continuous))
        )
    }

    private var favoriteButton: some View {
        Button(action: viewModel.toggleFavorite) {
            Image(viewModel.favoriteImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .padding(8)
                .background(Circle().fill(Color.white))
        }
        .buttonStyle(.plain)
    }

    private var playbackControls: some View {
        HStack(spacing: 40) {
            Button(action: viewModel.seekBackwardTenSeconds) {
                Image(systemName: "gobackward.10")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundStyle(Color(white: 0.33))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)

            Button(action: viewModel.togglePlayPause) {
                Image(viewModel.isPlaying ? "pause" : "play")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 38, height: 38)
            }
            .buttonStyle(.plain)

            Button(action: viewModel.seekForwardTenSeconds) {
                Image(systemName: "goforward.10")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundStyle(Color(white: 0.33))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }

    private var fullscreenButton: some View {
        Button(action: viewModel.openFullscreenPlayer) {
            Image("maximise")
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
        }
        .buttonStyle(.plain)
    }

    private var progressSlider: some View {
        Slider(
            value: Binding(
                get: { viewModel.progress },
                set: { viewModel.seekToProgress($0) }
            ),
            in: 0...1
        )
        .tint(.white)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Shared video section") {
    let viewModel = BreathingTechniqueType1ViewModel()
    viewModel.applyPreviewState()
    return BreathingExerciseVideoSectionView(viewModel: viewModel)
        .padding()
}
#endif
