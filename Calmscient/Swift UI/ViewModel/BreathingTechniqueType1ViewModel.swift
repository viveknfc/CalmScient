//
//  BreathingTechniqueType1ViewModel.swift
//  Calmscient
//
//  State, video playback, favorites, and navigation for 4-7-8 breathing (parity with `BreathingTechniqueType1`).
//
//  Vivek
//  20 May 2026
//

import AVFoundation
import AVKit
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class BreathingTechniqueType1ViewModel: ObservableObject, BreathingExerciseVideoViewModel {

    weak var hostViewController: UIViewController?

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

    private var anchorView: UIView? { hostViewController?.view }

    // MARK: - Lifecycle

    func onHostViewDidLoad() {
        reloadLocalizedStrings()
        loadFavoriteState()
        setupPlayer()
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
        tabBarController?.tabBar.isHidden = false
        tabBarController?.tabBar.selectedItem?.title = "main_tab_bar_home".localized
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
        screenTitle = "4-7-8 Breathing excercise".localized
        preparationHeader = "Preparation".localized
        preparationBody = "First find a comfortable seated position. Ensure that you are at ease before beginning the rhythmic breathing pattern.\n\nPlace the tip of your tongue gently against the tissue just behind your top front teeth".localized
        stepsSubtitle = "Let’s learn how to do the 4-7-8 breathing exercise.".localized
        steps = [
            BreathingTechniqueType1StepPresentation(
                id: 0,
                title: "Step 1: Emptying the lungs".localized,
                body: "Begin by completely emptying your lungs of air. Allow yourself a moment to release any tension.".localized
            ),
            BreathingTechniqueType1StepPresentation(
                id: 1,
                title: "Step 2: Inhaling quietly".localized,
                body: "Inhale quietly through your nose, counting to 4 seconds. Fell the breath entering your body, bringing calmness.".localized
            ),
            BreathingTechniqueType1StepPresentation(
                id: 2,
                title: "Step 3: Hold the breath".localized,
                body: "Hold your breath for  a steady count of 7 seconds. Embrace the stillness within, allowing the breath to settle.".localized
            ),
            BreathingTechniqueType1StepPresentation(
                id: 3,
                title: "Step 4: Force exhalation".localized,
                body: "Exhale forcefully through your mouth, pursing your lips, and create a distinct “whoosh” sound for 8 seconds. Feel the release of tension as you expel the breath.".localized
            ),
            BreathingTechniqueType1StepPresentation(
                id: 4,
                title: "Step 5: Repeat the process".localized,
                body: "Repeat this entire cycle up to 4 times. Each repetition contributes to a deepening sense of relaxation.".localized
            ),
        ]
        videoIntroText = "Now, let’s dive into it.\nPay careful attention to the following video.".localized
        bottomDescription = "Engage in this practice regularly, allowing the 4-7-8 technique to guide you towards a state of tranquility and mindful breathing.".localized
        completeButtonTitle = "Complete".localized
    }

    // MARK: - Navigation

    func openBack() {
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
        guard let player, let host = hostViewController else { return }
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
            request: ExerciseFavoriteToggleRequest(pageId: 1, exercise: .breathingTechnique1),
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
        applyFavoriteState(ExerciseFavoriteToggle.loadIsFav(exercise: .breathingTechnique1))
    }

    private func setupPlayer() {
        let urlKey = "https://media.calmscient.in/uploads/exercises-videos/4-7-8Breathing.mp4"
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
enum BreathingTechniqueType1Navigation {

    static func push(from host: UIViewController, animated: Bool = true) {
        guard let nav = host.navigationController else { return }
        nav.pushViewController(BreathingTechniqueType1HostingController(), animated: animated)
    }
}
