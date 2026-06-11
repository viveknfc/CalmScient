//
//  BasicKnowledgeVideoPlayerSectionView.swift
//  Calmscient
//
//  Inline AVPlayer surface with play/pause, favorite, fullscreen, and progress (parity with `BasicknowledgeVideo`).
//
//  Vivek
//  21 May 2026
//

import AVFoundation
import SwiftUI

@available(iOS 16.0, *)
struct BasicKnowledgeVideoPlayerSectionView: View {

    @ObservedObject var viewModel: BasicKnowledgeVideoViewModel

    private let videoBackground = Color(red: 0.851, green: 0.851, blue: 0.851)
    private let aspectRatio: CGFloat = 403 / 236
    private let playPauseCircleSize: CGFloat = 50
    private let playPauseCircleColor = Color(red: 0.43, green: 0.42, blue: 0.70)

    var body: some View {
        ZStack {
            videoBackground

            if let player = viewModel.player {
                BreathingTechniqueType1VideoPlayerRepresentable(player: player)
                    .aspectRatio(aspectRatio, contentMode: .fit)
            }

            VStack {
                HStack {
                    Spacer()
                    favoriteButton
                }
                .padding(12)

                Spacer()

                playPauseButton

                Spacer()

                progressSlider
                    .padding(.horizontal, 4)
                    .padding(.bottom, 4)
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
        .aspectRatio(aspectRatio, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 0, style: .continuous))
    }

    private var favoriteButton: some View {
        Button(action: viewModel.toggleFavorite) {
            Image(viewModel.favoriteImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .padding(6)
                .background(Circle().fill(Color.white))
        }
        .buttonStyle(.plain)
    }

    private var playPauseButton: some View {
        Button(action: viewModel.togglePlayPause) {
            if viewModel.isPlaying {
                ZStack {
                    Circle()
                        .fill(playPauseCircleColor.opacity(0.55))
                        .frame(width: playPauseCircleSize, height: playPauseCircleSize)
                    Image(systemName: "pause.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: playPauseCircleSize, height: playPauseCircleSize)
            } else {
                Image("play_button")
                    .resizable()
                    .scaledToFit()
                    .frame(width: playPauseCircleSize, height: playPauseCircleSize)
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: viewModel.isPlaying)
    }

    private var fullscreenButton: some View {
        Button(action: viewModel.openFullscreenPlayer) {
            Image("maximise")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
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
#Preview("Brain video player — play") {
    let viewModel = BasicKnowledgeVideoViewModel()
    viewModel.applyPreviewState()
    return BasicKnowledgeVideoPlayerSectionView(viewModel: viewModel)
        .padding(.horizontal, 16)
}

@available(iOS 16.0, *)
#Preview("Brain video player — pause") {
    let viewModel = BasicKnowledgeVideoViewModel()
    viewModel.applyPreviewState(isPlaying: true)
    return BasicKnowledgeVideoPlayerSectionView(viewModel: viewModel)
        .padding(.horizontal, 16)
}
#endif
