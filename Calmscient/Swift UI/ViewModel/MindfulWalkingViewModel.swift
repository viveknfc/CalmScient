//
//  MindfulWalkingViewModel.swift
//  Calmscient
//
//  State, audio playback, favorites, and navigation for mindful walking.
//
//  Vivek
//  26 May 2026
//

import AVFoundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class MindfulWalkingViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    // MARK: - SwiftUI navigation
    //
    // Set by `ExercisesTabView` when this screen is shown inside the Exercises
    // `NavigationStack`. When nil the screen falls back to the UIKit push/pop below,
    // which is what the Home ▸ favourites path (`ExcercisesTypeEnum.destVC`) still uses.
    var onOpenRoute: ((ExercisesRoute) -> Void)?
    var onClose: (() -> Void)?
    var onCloseToRoot: (() -> Void)?

    @Published private(set) var screenTitle: String = ""
    @Published private(set) var questionTitle: String = ""
    @Published private(set) var completeButtonTitle: String = ""
    @Published private(set) var benefits: [String] = []

    @Published private(set) var isFavorited = false
    @Published private(set) var isCompleteEnabled = false
    @Published private(set) var isPlayerReady = false
    @Published private(set) var isPlaying = false
    @Published private(set) var progress: CGFloat = 0

    private(set) var player: AVPlayer?
    private var statusObserver: NSKeyValueObservation?
    private var timeControlObserver: NSKeyValueObservation?
    private var progressObserverToken: Any?
    private var remainingTimeObserverToken: Any?

    private var isFav = 0
    /// Falls back to the key window so this screen still shows toasts when it is
    /// presented without a `hostViewController` (SwiftUI-navigated Exercises tab).
    private var anchorView: UIView? { Toast.resolvedAnchor(hostViewController?.view) }

    var favoriteImageName: String {
        isFavorited ? "redFav" : "fav"
    }

    var playPauseImageName: String {
        isPlaying ? MindfulWalkingPresentation.pauseImageName : MindfulWalkingPresentation.playImageName
    }

    // MARK: - Lifecycle

    func onHostViewDidLoad() {
        reloadLocalizedStrings()
        configureAudioSession()
        loadFavoriteState()
        setupPlayer()
    }

    /// Seeds the localized chrome up front so the navigation title is right on the
    /// very first SwiftUI body evaluation. The UIKit host set it in `viewWillAppear`,
    /// which on a `NavigationStack` lands *after* the first render — the title would
    /// pop in a beat late.
    init() {
        reloadLocalizedStrings()
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
    }

    func onHostWillDisappear() {
        player?.pause()
        isPlaying = false
    }

    func releasePlayerResources() {
        tearDownPlayer()
    }

    // MARK: - Localization

    func reloadLocalizedStrings() {
        screenTitle = MindfulWalkingPresentation.screenTitleKey.localized
        questionTitle = MindfulWalkingPresentation.questionTitleKey.localized
        completeButtonTitle = MindfulWalkingPresentation.completeButtonTitleKey.localized
        benefits = MindfulWalkingPresentation.benefitKeys.map { $0.localized }
    }

    // MARK: - Navigation

    func openBack() {
        if let onClose {
            onClose()
            return
        }
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    func completeTapped() {
        guard isCompleteEnabled else { return }
        openBack()
    }

    // MARK: - Audio controls

    func togglePlayPause() {
        guard isPlayerReady, let player else { return }

        if isPlaying {
            player.pause()
            isPlaying = false
            return
        }

        if ExerciseAudioSilentModeGuard.shouldBlockPlayback() {
            ExerciseAudioSilentModeGuard.showSilentModeToast(on: anchorView)
            return
        }

        player.play()
        isPlaying = true
    }

    func seekBackwardTenSeconds() {
        guard let player else { return }
        let currentTime = player.currentTime()
        let newTime = CMTimeSubtract(currentTime, CMTimeMakeWithSeconds(10, preferredTimescale: currentTime.timescale))
        if newTime.seconds.isFinite, newTime.seconds > 0 {
            player.seek(to: newTime)
        } else {
            player.seek(to: .zero)
        }
    }

    func seekForwardTenSeconds() {
        guard let player else { return }
        let currentTime = player.currentTime()
        let newTime = CMTimeAdd(currentTime, CMTimeMakeWithSeconds(10, preferredTimescale: currentTime.timescale))
        player.seek(to: newTime)
    }

    // MARK: - Favorite

    func toggleFavorite() {
        ExerciseFavoriteToggle.toggle(
            currentIsFav: isFav,
            request: ExerciseFavoriteToggleRequest(pageId: 1, exercise: .mindfulWalking),
            anchorView: anchorView
        ) { [weak self] newIsFav in
            self?.applyFavoriteState(newIsFav)
        }
    }

    // MARK: - Private

    private func configureAudioSession() {
        do {
            // .ambient respects the hardware silent switch.
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }

    private func setupPlayer() {
        guard let url = URL(string: MindfulWalkingPresentation.audioURLKey.localized) else { return }
        tearDownPlayer()

        let item = AVPlayerItem(url: url)
        item.preferredPeakBitRate = 1_000_000

        let newPlayer = AVPlayer(playerItem: item)
        newPlayer.automaticallyWaitsToMinimizeStalling = true
        player = newPlayer

        isPlaying = false
        isPlayerReady = false
        isCompleteEnabled = false
        progress = 0

        statusObserver = item.observe(\.status, options: [.new]) { [weak self] observedItem, _ in
            Task { @MainActor in
                self?.isPlayerReady = observedItem.status == .readyToPlay
            }
        }

        timeControlObserver = newPlayer.observe(\.timeControlStatus, options: [.new]) { [weak self] observedPlayer, _ in
            Task { @MainActor in
                if observedPlayer.timeControlStatus != .playing {
                    self?.isPlaying = false
                }
            }
        }

        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        progressObserverToken = newPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] _ in
            Task { @MainActor in
                self?.updateProgress()
            }
        }

        remainingTimeObserverToken = newPlayer.observeRemainingTime(threshold: 10) { [weak self] canEnable in
            Task { @MainActor in
                self?.isCompleteEnabled = canEnable
            }
        }
    }

    private func tearDownPlayer() {
        statusObserver = nil
        timeControlObserver = nil

        if let token = progressObserverToken {
            player?.removeTimeObserver(token)
            progressObserverToken = nil
        }
        if let token = remainingTimeObserverToken {
            player?.removeTimeObserver(token)
            remainingTimeObserverToken = nil
        }

        player?.pause()
        player = nil
    }

    private func updateProgress() {
        guard let player, let duration = player.currentItem?.duration.seconds, duration.isFinite, duration > 0 else {
            progress = 0
            return
        }
        let current = player.currentTime().seconds
        progress = CGFloat(max(0, min(1, current / duration)))
    }

    private func loadFavoriteState() {
        applyFavoriteState(ExerciseFavoriteToggle.loadIsFav(exercise: .mindfulWalking))
    }

    private func applyFavoriteState(_ newIsFav: Int) {
        isFav = newIsFav
        isFavorited = newIsFav == 1
    }

    #if DEBUG
    func applyPreviewState(
        isPlaying: Bool = false,
        progress: CGFloat = 0.22,
        isCompleteEnabled: Bool = false,
        isFavorited: Bool = false
    ) {
        reloadLocalizedStrings()
        self.isPlaying = isPlaying
        self.progress = progress
        self.isCompleteEnabled = isCompleteEnabled
        self.isFavorited = isFavorited
        isPlayerReady = true
    }
    #endif
}

// MARK: - Navigation

@available(iOS 16.0, *)
enum MindfulWalkingNavigation {
    static func push(from host: UIViewController, animated: Bool = true) {
        guard let nav = host.navigationController else { return }
        nav.pushViewController(MindfulWalkingHostingController(), animated: animated)
    }
}
