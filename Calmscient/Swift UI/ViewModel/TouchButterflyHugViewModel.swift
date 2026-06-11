//
//  TouchButterflyHugViewModel.swift
//  Calmscient
//
//  State, navigation, and favorites for the Touch and Butterfly Hug exercise.
//
//  Vivek
//  26 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class TouchButterflyHugViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var screenTitle: String = ""
    @Published private(set) var introDescription: String = ""
    @Published private(set) var isFavorited: Bool = false

    private var isFav: Int = 0
    private var anchorView: UIView? { hostViewController?.view }

    var favoriteImageName: String { isFavorited ? "redFav" : "fav" }

    func onHostWillAppear() {
        reloadLocalizedStrings()
        loadFavoriteState()
    }

    func reloadLocalizedStrings() {
        screenTitle = TouchButterflyHugPresentation.screenTitleKey.localized
        introDescription = TouchButterflyHugPresentation.introDescriptionKey.localized
    }

    // MARK: - Navigation

    func openBack() {
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    func openHowTo() {
        guard let hostViewController else { return }
        TouchButterflyHowToNavigation.push(from: hostViewController)
    }

    func completeTapped() {
        hostViewController?.navigationController?.popToRootViewController(animated: true)
    }

    // MARK: - Favorite

    func toggleFavorite() {
        ExerciseFavoriteToggle.toggle(
            currentIsFav: isFav,
            request: ExerciseFavoriteToggleRequest(pageId: 1, exercise: .touchAndButterfly),
            anchorView: anchorView
        ) { [weak self] newIsFav in
            self?.applyFavoriteState(newIsFav)
        }
    }

    private func loadFavoriteState() {
        applyFavoriteState(ExerciseFavoriteToggle.loadIsFav(exercise: .touchAndButterfly))
    }

    private func applyFavoriteState(_ newIsFav: Int) {
        isFav = newIsFav
        isFavorited = newIsFav == 1
    }

    #if DEBUG
    func applyPreviewState() {
        reloadLocalizedStrings()
        isFavorited = false
        isFav = 0
    }
    #endif
}

// MARK: - Navigation

@available(iOS 16.0, *)
enum TouchButterflyIntroNavigation {
    static func push(from host: UIViewController, animated: Bool = true) {
        guard let nav = host.navigationController else { return }
        nav.pushViewController(TouchButterflyIntroHostingController(), animated: animated)
    }
}

@available(iOS 16.0, *)
enum TouchButterflyHowToNavigation {
    static func push(from host: UIViewController, animated: Bool = true) {
        guard let nav = host.navigationController else { return }
        nav.pushViewController(TouchButterflyHowToHostingController(), animated: animated)
    }
}

