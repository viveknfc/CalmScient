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

    // MARK: - SwiftUI navigation
    //
    // Set by `ExercisesTabView` when this screen is shown inside the Exercises
    // `NavigationStack`. When nil the screen falls back to the UIKit push/pop below,
    // which is what the Home ▸ favourites path (`ExcercisesTypeEnum.destVC`) still uses.
    var onOpenRoute: ((ExercisesRoute) -> Void)?
    var onClose: (() -> Void)?
    var onCloseToRoot: (() -> Void)?

    @Published private(set) var screenTitle: String = ""
    @Published private(set) var cards: [ExercisesCardItem] = []

    /// Seeds the localized chrome up front so the navigation title is right on the
    /// very first SwiftUI body evaluation. The UIKit host set it in `viewWillAppear`,
    /// which on a `NavigationStack` lands *after* the first render — the title would
    /// pop in a beat late.
    init() {
        reloadLocalizedStrings()
    }

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
        if let onOpenRoute {
            switch card.destination {
            case .mindfulness:                 onOpenRoute(.mindfulness)
            case .progressiveMuscleRelaxation: onOpenRoute(.progressive)
            case .touchAndButterflyHug:        onOpenRoute(.touchButterflyIntro)
            case .handOverYourHeart:           onOpenRoute(.handOverYourHeart)
            case .mindfulWalking:              onOpenRoute(.mindfulWalking)
            case .movementDance:               onOpenRoute(.movementDance)
            case .movementRunning:             onOpenRoute(.movementRunning)
            case .mindfulBodyMovement:         onOpenRoute(.mindfulBodyMovement)
            case .breathingTechnique:          onOpenRoute(.breathingTechnique)
            }
            return
        }

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


    #if DEBUG
    func applyPreviewState() {
        reloadLocalizedStrings()
        buildCards()
    }
    #endif
}

