//
//  MovementDanceViewModel.swift
//  Calmscient
//
//  State, favorites, and navigation for movement: dance.
//
//  Vivek
//  26 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class MovementDanceViewModel: ObservableObject {

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
        screenTitle = MovementDancePresentation.screenTitleKey.localized
        descriptionText = MovementDancePresentation.descriptionKey.localized
        completeButtonTitle = MovementDancePresentation.completeButtonTitleKey.localized
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
            request: ExerciseFavoriteToggleRequest(pageId: 1, exercise: .movementDance),
            anchorView: anchorView
        ) { [weak self] newIsFav in
            self?.applyFavoriteState(newIsFav)
        }
    }

    private func loadFavoriteState() {
        applyFavoriteState(ExerciseFavoriteToggle.loadIsFav(exercise: .movementDance))
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
enum MovementDanceNavigation {
    static func push(from host: UIViewController, animated: Bool = true) {
        guard let nav = host.navigationController else { return }
        nav.pushViewController(MovementDanceHostingController(), animated: animated)
    }
}
