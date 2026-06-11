//
//  ProgressiveAudioControlsView.swift
//  Calmscient
//
//  Rewind, play/pause, and forward controls for progressive exercise audio.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ProgressiveAudioControlsView: View {

    let rewindImageName: String
    let playPauseImageName: String
    let forwardImageName: String
    let isPlayerReady: Bool
    let onRewind: () -> Void
    let onPlayPause: () -> Void
    let onForward: () -> Void

    var body: some View {
        HStack(spacing: 35) {
            Button(action: onRewind) {
                Image(rewindImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
            }
            .buttonStyle(.plain)

            Button(action: onPlayPause) {
                Image(playPauseImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
            }
            .buttonStyle(.plain)
            .disabled(!isPlayerReady)
            .opacity(isPlayerReady ? 1 : 0.5)

            Button(action: onForward) {
                Image(forwardImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
            }
            .buttonStyle(.plain)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Progressive controls") {
    ProgressiveAudioControlsView(
        rewindImageName: "rewind",
        playPauseImageName: "playAudio",
        forwardImageName: "forwardAudio",
        isPlayerReady: true,
        onRewind: {},
        onPlayPause: {},
        onForward: {}
    )
}
#endif
