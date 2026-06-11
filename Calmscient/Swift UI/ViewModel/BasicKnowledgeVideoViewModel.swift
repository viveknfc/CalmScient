//
//  BasicKnowledgeVideoViewModel.swift
//  Calmscient
//
//  State, video playback, favorites, API, and navigation for the brain video screen (parity with `BasicknowledgeVideo`).
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
final class BasicKnowledgeVideoViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var navigationChromeTitle: String = ""
    @Published private(set) var questionTitle: String = ""
    @Published private(set) var videoBrandTitle: String = ""
    @Published private(set) var videoSubtitle: String = ""
    @Published private(set) var bodyText: String = ""
    @Published private(set) var completeButtonTitle: String = ""

    @Published var isPlaying = false
    @Published var progress: Float = 0
    @Published var isCompleteEnabled = false
    @Published private(set) var isFavorited = false
    @Published private(set) var isCompleting = false

    private(set) var player: AVPlayer?

    private var timeObserverToken: Any?
    private var remainingTimeObserverToken: Any?
    private var timeControlStatusObservation: NSKeyValueObservation?
    private var playbackEndObserver: NSObjectProtocol?
    private var isFav = 0
    private(set) var sectionId: Int = 0

    private var anchorView: UIView? { hostViewController?.view }

    private var navigationController: UINavigationController? {
        hostViewController?.navigationController
    }

    private var tabBarController: UITabBarController? {
        hostViewController?.tabBarController
    }

    // MARK: - Configuration

    func configure(sectionId: Int, navigationTitle: String? = nil) {
        self.sectionId = sectionId
        if let navigationTitle, !navigationTitle.isEmpty {
            navigationChromeTitle = navigationTitle
        }
    }

    // MARK: - Lifecycle

    func onHostViewDidLoad() {
        reloadLocalizedStrings()
        setupPlayer()
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = false
        fetchFavoriteState()
    }

    func onHostWillDisappear() {
        if let player {
            player.pause()
            syncPlayingState(with: player)
        } else {
            isPlaying = false
        }
    }

    func releasePlayerResources() {
        tearDownPlayerObservers()
    }

    // MARK: - Localization

    func reloadLocalizedStrings() {
        if navigationChromeTitle.isEmpty {
            navigationChromeTitle = "Basic Knowledge".localized
        }
        questionTitle = "DRINKING_CONTROL_Consequence_What_Happens_To_Your_Brain_When_You_Drink".localized
        videoBrandTitle = "BASIC_KNOWLEDGE_Tipsy_Truth".localized
        videoSubtitle = "DRINKING_CONTROL_Video_Sub_Header".localized
        bodyText = "This video explains the impact of alcohol on the brain and its subsequent effects. Having this knowledge will help you consider your drinking habits.".localized
        completeButtonTitle = "Complete".localized
    }

    // MARK: - Navigation

    func openBack() {
        navigationController?.popViewController(animated: true)
    }

    func completeTapped() {
        guard isCompleteEnabled,
              let host = hostViewController,
              let userInfo = ApplicationSharedInfo.shared.loginResponse,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }

        isCompleting = true
        anchorView?.showToastActivity()

        let params: [String: Any] = [
            "isCompleted": 1,
            "patientId": userInfo.patientID,
            "sectionId": sectionId,
        ]

        APIService.DUpdateBasicKAPICalling(
            host,
            params: params,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleCompleteResponse(response)
            }
        }
    }

    private func handleCompleteResponse(_ response: AnyObject) {
        isCompleting = false
        anchorView?.hideToastActivity()

        guard response is [String: Any] else {
            print("BasicKnowledgeVideoViewModel: unsupported complete response — \(type(of: response))")
            return
        }

        openBack()
    }

    // MARK: - Video

    func togglePlayPause() {
        guard let player else { return }
        if player.timeControlStatus == .playing {
            player.pause()
        } else {
            player.play()
        }
        syncPlayingState(with: player)
    }

    func seekToProgress(_ value: Float) {
        guard let player, let item = player.currentItem else { return }
        let seconds = Double(value) * item.duration.seconds
        guard seconds.isFinite else { return }
        player.seek(to: CMTime(seconds: seconds, preferredTimescale: 600))
    }

    func openFullscreenPlayer() {
        guard let player, let host = hostViewController else { return }
        let controller = AVPlayerViewController()
        controller.player = player
        controller.modalPresentationStyle = .overFullScreen
        host.present(controller, animated: true) {
            player.play()
            self.syncPlayingState(with: player)
        }
    }

    var favoriteImageName: String {
        isFavorited ? "redFav" : "fav"
    }

    // MARK: - Favorite

    func toggleFavorite() {
        ExerciseFavoriteToggle.toggle(
            currentIsFav: isFav,
            request: ExerciseFavoriteToggleRequest(
                pageId: BasicKnowledgeVideoPresentation.favoritePageId,
                title: BasicKnowledgeVideoPresentation.favoriteAPITitle
            ),
            anchorView: anchorView
        ) { [weak self] newIsFav in
            self?.applyFavoriteState(newIsFav)
        }
    }

    private func applyFavoriteState(_ newIsFav: Int) {
        isFav = newIsFav
        isFavorited = newIsFav == 1
    }

    func fetchFavoriteState() {
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken,
              let host = hostViewController else {
            return
        }

        anchorView?.showToastActivity()

        let params: [String: Any] = [
            "plId": userInfo.patientLocationID,
            "patientId": userInfo.patientID,
            "parentId": 0,
            "clientId": userInfo.clientID,
        ]

        APIService.getPatientFavoritesAPICalling(
            host,
            params: params,
            method: "POST",
            accessToken: token,
            acces: true,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleFetchFavoriteResponse(response)
            }
        }
    }

    private func handleFetchFavoriteResponse(_ response: AnyObject) {
        anchorView?.hideToastActivity()

        guard let dict = response as? [String: Any],
              let data = try? JSONSerialization.data(withJSONObject: dict) else {
            print("BasicKnowledgeVideoViewModel: unexpected favorites response")
            return
        }

        do {
            let decoded = try JSONDecoder().decode(FavoritesResponse.self, from: data)
            if let match = decoded.favorites.first(where: {
                $0.title == BasicKnowledgeVideoPresentation.favoriteAPITitle
            }) {
                applyFavoriteState(match.isFavorite)
            }
        } catch {
            print("BasicKnowledgeVideoViewModel: favorites decode error — \(error)")
        }
    }

    // MARK: - Private

    private func setupPlayer() {
        guard let url = URL(string: BasicKnowledgeVideoPresentation.videoURLString) else { return }

        tearDownPlayerObservers()

        let newPlayer = AVPlayer(url: url)
        newPlayer.pause()
        player = newPlayer
        isPlaying = false
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

        timeControlStatusObservation = newPlayer.observe(\.timeControlStatus, options: [.initial, .new]) { [weak self] player, _ in
            Task { @MainActor in
                self?.syncPlayingState(with: player)
            }
        }

        if let item = newPlayer.currentItem {
            playbackEndObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: item,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor in
                    self?.handlePlaybackEnded()
                }
            }
        }
    }

    private func syncPlayingState(with player: AVPlayer) {
        isPlaying = player.timeControlStatus == .playing
    }

    private func handlePlaybackEnded() {
        player?.pause()
        player?.seek(to: .zero)
        isPlaying = false
        progress = 0
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
        timeControlStatusObservation?.invalidate()
        timeControlStatusObservation = nil
        if let playbackEndObserver {
            NotificationCenter.default.removeObserver(playbackEndObserver)
            self.playbackEndObserver = nil
        }
        player?.pause()
        isPlaying = false
        player = nil
    }

    #if DEBUG
    func applyPreviewState(isPlaying: Bool = false) {
        reloadLocalizedStrings()
        isCompleteEnabled = false
        isFavorited = false
        progress = 0.25
        self.isPlaying = isPlaying
    }
    #endif
}

// MARK: - Navigation

@available(iOS 16.0, *)
enum BasicKnowledgeVideoNavigation {

    @MainActor
    static func push(
        from host: UIViewController,
        sectionId: Int,
        navigationTitle: String? = nil,
        animated: Bool = true
    ) {
        guard let nav = host.navigationController else { return }

        let backItem = UIBarButtonItem()
        backItem.title = ""
        host.navigationItem.backBarButtonItem = backItem

        let videoHost = BasicKnowledgeVideoHostingController()
        videoHost.viewModel.configure(sectionId: sectionId, navigationTitle: navigationTitle)
        nav.pushViewController(videoHost, animated: animated)
    }
}
