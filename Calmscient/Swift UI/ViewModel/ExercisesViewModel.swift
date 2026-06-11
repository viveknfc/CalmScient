//
//  ExercisesViewModel.swift
//  Calmscient
//
//  Exercises grid state + navigation (parity with legacy `Excercises`).
//
//  Vivek
//  26 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class ExercisesViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var screenTitle: String = ""
    @Published private(set) var cards: [ExercisesCardItem] = []

    func onHostWillAppear() {
        reloadLocalizedStrings()
        if cards.isEmpty { buildCards() }
    }

    func reloadLocalizedStrings() {
        screenTitle = "Exercises".localized
    }

    private func buildCards() {
        cards = [
            ExercisesCardItem(
                id: 0,
                titleKey: "Mindfulness - what is it?",
                imageName: "mindfulness",
                destination: .mindfulness
            ),
            ExercisesCardItem(
                id: 1,
                titleKey: "Progressive muscle relaxation",
                imageName: "progressiveWithHeadset",
                destination: .progressiveMuscleRelaxation
            ),
            ExercisesCardItem(
                id: 2,
                titleKey: "Touch and the butterfly hug",
                imageName: "touchAndButterfly",
                destination: .touchAndButterflyHug
            ),
            ExercisesCardItem(
                id: 3,
                titleKey: "Hand over your heart",
                imageName: "handover",
                destination: .handOverYourHeart
            ),
            ExercisesCardItem(
                id: 4,
                titleKey: "Mindful walking",
                imageName: "mindfulWalking_index",
                destination: .mindfulWalking
            ),
            ExercisesCardItem(
                id: 5,
                titleKey: "Movement: dance",
                imageName: "movement",
                destination: .movementDance
            ),
            ExercisesCardItem(
                id: 6,
                titleKey: "Movement: running",
                imageName: "movementRunning",
                destination: .movementRunning
            ),
            ExercisesCardItem(
                id: 7,
                titleKey: "Mindful body movement",
                imageName: "MindFulBodyMovement",
                destination: .mindfulBodyMovement
            ),
            ExercisesCardItem(
                id: 8,
                titleKey: "Breathing technique",
                imageName: "breathingTechnique",
                destination: .breathingTechnique
            ),
        ]
    }

    // MARK: - Navigation

    func openCard(_ card: ExercisesCardItem) {
        guard let host = hostViewController else { return }

        switch card.destination {
        case .mindfulness:
            MindfulnessNavigation.push(from: host)
        case .progressiveMuscleRelaxation:
            ProgressiveNavigation.push(from: host)
        case .touchAndButterflyHug:
            TouchButterflyIntroNavigation.push(from: host)
        case .handOverYourHeart:
            HandOverYourHeartNavigation.push(from: host)
        case .mindfulWalking:
            MindfulWalkingNavigation.push(from: host)
        case .movementDance:
            MovementDanceNavigation.push(from: host)
        case .movementRunning:
            MovementRunningNavigation.push(from: host)
        case .mindfulBodyMovement:
            MindfulBodyMovementNavigation.push(from: host)
        case .breathingTechnique:
            BreathingTechniqueNavigation.push(from: host)
        }
    }

    func openCitationSources() {
        guard let nav = hostViewController?.navigationController else { return }
        CitationWebNavigation.pushSourcesAndCitations(from: nav)
    }

    private func pushStoryboardExercise(from host: UIViewController, storyboardId: String) {
        let storyboard = UIStoryboard(name: "Excercises", bundle: nil)
        let destination = storyboard.instantiateViewController(withIdentifier: storyboardId)
        host.navigationController?.pushViewController(destination, animated: true)
    }

    #if DEBUG
    func applyPreviewState() {
        reloadLocalizedStrings()
        buildCards()
    }
    #endif
}

