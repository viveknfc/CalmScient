//
//  MindfulBreathingViewModel.swift
//  Calmscient
//
//  State, video playback, favorites, and navigation for mindful breathing (parity with `MindfulBreathing`).
//
//  Vivek
//  21 May 2026
//

import AVFoundation
import AVKit
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class MindfulBreathingViewModel: ObservableObject, BreathingExerciseVideoViewModel {

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
    @Published private(set) var preparationHeader: String = ""
    @Published private(set) var preparationBody: String = ""
    @Published private(set) var stepsSubtitle: String = ""
    @Published private(set) var steps: [BreathingTechniqueType1StepPresentation] = []
    @Published private(set) var videoIntroText: String = ""
    @Published private(set) var bottomDescription: String = ""
    @Published private(set) var completeButtonTitle: String = ""

    @Published var isPlaying = false
    @Published var showsThumbnail = true
    @Published var progress: Float = 0
    @Published var isCompleteEnabled = false
    @Published private(set) var isFavorited = false

    private(set) var player: AVPlayer?
    private var timeObserverToken: Any?
    private var remainingTimeObserverToken: Any?
    private var isFav = 0

    /// Falls back to the key window so this screen still shows toasts when it is
    /// presented without a `hostViewController` (SwiftUI-navigated Exercises tab).
    private var anchorView: UIView? { Toast.resolvedAnchor(hostViewController?.view) }

    // MARK: - Lifecycle

    func onHostViewDidLoad() {
        reloadLocalizedStrings()
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
        tabBarController?.tabBar.isHidden = false
        // Removed: this hard-coded the *Home* tab label onto whichever tab was
        // selected, renaming the Exercises tab. `MainTabStoryboardHost.updateUIViewController`
        // already restores each tab's correct title.
    }

    func onHostWillDisappear() {
        player?.pause()
        isPlaying = false
    }

    func releasePlayerResources() {
        tearDownPlayerObservers()
    }

    // MARK: - Localization

    func reloadLocalizedStrings() {
        screenTitle = "Mindful breathing exercise".localized
        preparationHeader = "Preparation".localized
        preparationBody = "First find a comfortable to either sit down or lay down. You can close your eyes if you want to.".localized
        stepsSubtitle = "Let’s learn how to do the mindful breathing exercise.".localized
        steps = [
            BreathingTechniqueType1StepPresentation(
                id: 0,
                title: "Step 1: Inhale".localized,
                body: "Inhale through your nose until the tummy expands.".localized
            ),
            BreathingTechniqueType1StepPresentation(
                id: 1,
                title: "Step 2: Exhale slowly and repeat it".localized,
                body: "Exhale slowly through your mouse. And repeat the process.".localized
            ),
            BreathingTechniqueType1StepPresentation(
                id: 2,
                title: "Step 3: Focus on the breath".localized,
                body: "Once settled into the pattern, focus on the breath coming in through the nose and out through the mouth".localized
            ),
            BreathingTechniqueType1StepPresentation(
                id: 3,
                title: "Step 4: Focus on the tummy".localized,
                body: "Notice the rise and fall of the tummy as the breath come in and out".localized
            ),
            BreathingTechniqueType1StepPresentation(
                id: 4,
                title: "Step 5: Focus on the mind".localized,
                body: "As thoughts come into the head, notice that they are there without judgment, then let them go and bring the attention back to the breathing.".localized
            ),
            BreathingTechniqueType1StepPresentation(
                id: 5,
                title: "Step 6: Focus on the connection between mind and body.".localized,
                body: "Carry on until feeling calm, then start to be aware of how the body and mind feel.".localized
            ),
        ]
        videoIntroText = "Now, let’s dive into it.\nPay careful attention to the following video.".localized
        bottomDescription = "Engage in this practice regularly, allowing the diaphragmatic breathing technique to guide you towards a state of tranquility and mindful breathing.".localized
        completeButtonTitle = "Complete".localized
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

    // MARK: - Video

    func togglePlayPause() {
        guard let player else { return }
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            showsThumbnail = false
            player.play()
            isPlaying = true
        }
    }

    func seekForwardTenSeconds() {
        guard let player, let duration = player.currentItem?.duration else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(duration)
        let newTime = min(currentTime + 10, durationSeconds)
        player.seek(to: CMTime(seconds: newTime, preferredTimescale: 600))
    }

    func seekBackwardTenSeconds() {
        guard let player else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = max(currentTime - 10, 0)
        player.seek(to: CMTime(seconds: newTime, preferredTimescale: 600))
    }

    func seekToProgress(_ value: Float) {
        guard let player, let item = player.currentItem else { return }
        let seconds = Double(value) * item.duration.seconds
        player.seek(to: CMTime(seconds: seconds, preferredTimescale: 600))
    }

    func openFullscreenPlayer() {
        // `hostViewController` is nil when this screen is shown from the SwiftUI
        // Exercises tab; fall back to the topmost controller for presentation.
        guard let player,
              let host = hostViewController ?? UIApplication.topViewController() else { return }
        let controller = AVPlayerViewController()
        controller.player = player
        controller.modalPresentationStyle = .overFullScreen
        host.present(controller, animated: true) {
            player.play()
            self.showsThumbnail = false
            self.isPlaying = true
        }
    }

    var favoriteImageName: String {
        isFavorited ? "redFav" : "fav"
    }

    // MARK: - Favorite

    func toggleFavorite() {
        ExerciseFavoriteToggle.toggle(
            currentIsFav: isFav,
            request: ExerciseFavoriteToggleRequest(pageId: 1, exercise: .breathingTechnique2),
            anchorView: anchorView
        ) { [weak self] newIsFav in
            self?.applyFavoriteState(newIsFav)
        }
    }

    private func applyFavoriteState(_ newIsFav: Int) {
        isFav = newIsFav
        isFavorited = newIsFav == 1
    }

    // MARK: - Private

    private var tabBarController: UITabBarController? {
        hostViewController?.tabBarController
    }

    private func loadFavoriteState() {
        applyFavoriteState(ExerciseFavoriteToggle.loadIsFav(exercise: .breathingTechnique2))
    }

    private func setupPlayer() {
        let urlKey = "https://media.calmscient.in/uploads/exercises-videos/Mindfulbreathing.mp4"
        guard let url = URL(string: urlKey.localized) else { return }

        tearDownPlayerObservers()

        let newPlayer = AVPlayer(url: url)
        newPlayer.pause()
        player = newPlayer
        isPlaying = false
        showsThumbnail = true
        progress = 0
        isCompleteEnabled = false

        let interval = CMTime(seconds: 1, preferredTimescale: 600)
        timeObserverToken = newPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] _ in
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

    private func updateProgress() {
        guard let player, let item = player.currentItem else { return }
        let currentTime = player.currentTime().seconds
        let duration = item.duration.seconds
        guard duration.isFinite, duration > 0 else { return }
        progress = Float(currentTime / duration)
    }

    private func tearDownPlayerObservers() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
        if let token = remainingTimeObserverToken {
            player?.removeTimeObserver(token)
            remainingTimeObserverToken = nil
        }
        player?.pause()
        player = nil
    }

    #if DEBUG
    func applyPreviewState() {
        reloadLocalizedStrings()
        isCompleteEnabled = false
        isFavorited = false
        progress = 0.35
    }
    #endif
}

// MARK: - Navigation

@available(iOS 16.0, *)
enum MindfulBreathingNavigation {

    static func push(from host: UIViewController, animated: Bool = true) {
        guard let nav = host.navigationController else { return }
        nav.pushViewController(MindfulBreathingHostingController(), animated: animated)
    }
}
