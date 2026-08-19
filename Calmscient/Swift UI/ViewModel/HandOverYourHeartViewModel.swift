//
//  HandOverYourHeartViewModel.swift
//  Calmscient
//
//  State, favorites, and navigation for hand over your heart.
//
//  Vivek
//  26 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class HandOverYourHeartViewModel: ObservableObject {

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
    @Published private(set) var howToTitle: String = ""
    @Published private(set) var bulletSteps: [String] = []
    @Published private(set) var isFavorited: Bool = false

    private var isFav: Int = 0
    /// Falls back to the key window so this screen still shows toasts when it is
    /// presented without a `hostViewController` (SwiftUI-navigated Exercises tab).
    private var anchorView: UIView? { Toast.resolvedAnchor(hostViewController?.view) }

    var favoriteImageName: String {
        isFavorited ? "redFav" : "fav"
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
        loadFavoriteState()
    }

    func reloadLocalizedStrings() {
        screenTitle = HandOverYourHeartPresentation.screenTitleKey.localized
        howToTitle = HandOverYourHeartPresentation.howToTitleKey.localized
        bulletSteps = HandOverYourHeartPresentation.stepKeys.map { $0.localized }
    }

    func openBack() {
        if let onClose {
            onClose()
            return
        }
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    func completeTapped() {
        if let onClose {
            onClose()
            return
        }
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    func toggleFavorite() {
        ExerciseFavoriteToggle.toggle(
            currentIsFav: isFav,
            request: ExerciseFavoriteToggleRequest(pageId: 1, exercise: .handOverHeart),
            anchorView: anchorView
        ) { [weak self] newIsFav in
            self?.applyFavoriteState(newIsFav)
        }
    }

    private func loadFavoriteState() {
        applyFavoriteState(ExerciseFavoriteToggle.loadIsFav(exercise: .handOverHeart))
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
enum HandOverYourHeartNavigation {
    static func push(from host: UIViewController, animated: Bool = true) {
        guard let nav = host.navigationController else { return }
        nav.pushViewController(HandOverYourHeartHostingController(), animated: animated)
    }
}
