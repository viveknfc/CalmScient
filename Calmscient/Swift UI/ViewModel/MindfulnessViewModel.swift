//
//  MindfulnessViewModel.swift
//  Calmscient
//
//  Six-step mindfulness exercise flow (parity with legacy `MindfulNess`).
//
//  Vivek
//  26 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class MindfulnessViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var screenTitle: String = ""
    @Published private(set) var stepIndex: Int = 0
    @Published private(set) var step: MindfulnessStepPresentation = MindfulnessPresentation.step(at: 0, isDarkMode: false)
    @Published private(set) var completeButtonTitle: String = ""
    @Published private(set) var isFavorited: Bool = false
    @Published private(set) var favoriteImageName: String = "fav"

    private var isFav: Int = 0

    private var isDarkMode: Bool {
        (UserDefaults.standard.value(forKey: "isDarkMode") ?? false) as? Bool ?? false
    }

    // MARK: - Lifecycle

    func onHostWillAppear() {
        screenTitle = "Mindfulness - what is it?".localized
        completeButtonTitle = "Complete".localized
        loadFavoriteState()
        applyStep(animated: false)
    }

    // MARK: - Navigation

    func openBack() {
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    func goToPreviousStep() {
        guard stepIndex > 0 else { return }
        stepIndex -= 1
        applyStep(animated: true)
    }

    func goToNextStep() {
        guard stepIndex < MindfulnessPresentation.stepCount - 1 else { return }
        stepIndex += 1
        applyStep(animated: true)
    }

    func completeTapped() {
        openBack()
    }

    // MARK: - Favorite

    func toggleFavorite() {
        ExerciseFavoriteToggle.toggle(
            currentIsFav: isFav,
            request: ExerciseFavoriteToggleRequest(pageId: 6, exercise: .mindfulness),
            anchorView: hostViewController?.view
        ) { [weak self] newIsFav in
            self?.applyFavoriteState(newIsFav)
        }
    }

    // MARK: - Private

    private func applyStep(animated: Bool) {
        step = MindfulnessPresentation.step(at: stepIndex, isDarkMode: isDarkMode)
        if animated {
            // Published `step` drives SwiftUI updates.
        }
    }

    private func loadFavoriteState() {
        applyFavoriteState(ExerciseFavoriteToggle.loadIsFav(exercise: .mindfulness))
    }

    private func applyFavoriteState(_ newIsFav: Int) {
        isFav = newIsFav
        isFavorited = newIsFav == 1
        favoriteImageName = isFavorited ? "redFav" : "fav"
    }

    #if DEBUG
    func applyPreviewState(stepIndex: Int = 0) {
        self.stepIndex = min(max(stepIndex, 0), MindfulnessPresentation.stepCount - 1)
        screenTitle = "Mindfulness - what is it?".localized
        completeButtonTitle = "Complete".localized
        applyFavoriteState(0)
        applyStep(animated: false)
    }
    #endif
}

// MARK: - Navigation

@available(iOS 16.0, *)
enum MindfulnessNavigation {

    static func push(from host: UIViewController, animated: Bool = true) {
        guard let nav = host.navigationController else { return }
        nav.pushViewController(MindfulnessHostingController(), animated: animated)
    }
}
