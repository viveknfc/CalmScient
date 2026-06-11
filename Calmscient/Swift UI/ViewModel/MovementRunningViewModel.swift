//
//  MovementRunningViewModel.swift
//  Calmscient
//
//  State, favorites, and navigation for movement: running.
//
//  Vivek
//  26 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class MovementRunningViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var screenTitle: String = ""
    @Published private(set) var descriptionText: String = ""
    @Published private(set) var completeButtonTitle: String = ""
    @Published private(set) var isFavorited = false

    private var isFav = 0
    private var anchorView: UIView? { hostViewController?.view }

    var favoriteImageName: String {
        isFavorited ? "redFav" : "fav"
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
        loadFavoriteState()
    }

    func reloadLocalizedStrings() {
        screenTitle = MovementRunningPresentation.screenTitleKey.localized
        descriptionText = MovementRunningPresentation.descriptionKey.localized
        completeButtonTitle = MovementRunningPresentation.completeButtonTitleKey.localized
    }

    func openBack() {
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    func completeTapped() {
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    func toggleFavorite() {
        ExerciseFavoriteToggle.toggle(
            currentIsFav: isFav,
            request: ExerciseFavoriteToggleRequest(pageId: 1, exercise: .movementRunning),
            anchorView: anchorView
        ) { [weak self] newIsFav in
            self?.applyFavoriteState(newIsFav)
        }
    }

    private func loadFavoriteState() {
        applyFavoriteState(ExerciseFavoriteToggle.loadIsFav(exercise: .movementRunning))
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
enum MovementRunningNavigation {
    static func push(from host: UIViewController, animated: Bool = true) {
        guard let nav = host.navigationController else { return }
        nav.pushViewController(MovementRunningHostingController(), animated: animated)
    }
}
