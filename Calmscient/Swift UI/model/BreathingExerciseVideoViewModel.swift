//
//  BreathingExerciseVideoViewModel.swift
//  Calmscient
//
//  Shared video controls contract for breathing exercise detail screens.
//
//  Vivek
//  21 May 2026
//

import AVFoundation
import SwiftUI

@available(iOS 16.0, *)
@MainActor
protocol BreathingExerciseVideoViewModel: ObservableObject {
    var videoIntroText: String { get }
    var isPlaying: Bool { get }
    var showsThumbnail: Bool { get }
    var progress: Float { get }
    var player: AVPlayer? { get }
    var favoriteImageName: String { get }

    func togglePlayPause()
    func seekForwardTenSeconds()
    func seekBackwardTenSeconds()
    func seekToProgress(_ value: Float)
    func openFullscreenPlayer()
    func toggleFavorite()
}
