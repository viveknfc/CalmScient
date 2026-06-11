//
//  BreathingTechniqueViewModel.swift
//  Calmscient
//
//  State and navigation for the breathing technique index (parity with `BreathingTechnique`).
//
//  Vivek
//  20 May 2026
//

import SwiftUI
import UIKit

@MainActor
final class BreathingTechniqueViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var exerciseRows: [BreathingExerciseRowPresentation] = []
    @Published private(set) var sectionTitle: String = ""
    @Published private(set) var screenTitle: String = ""

    let heroImageName = "breathingTechnique"

    func onHostWillAppear() {
        reloadLocalizedStrings()
    }

    func reloadLocalizedStrings() {
        screenTitle = "Breathing technique".localized
        sectionTitle = "Breathing exercises".localized
        exerciseRows = [
            BreathingExerciseRowPresentation(id: 0, title: "4-7-8 Breathing exercise".localized),
            BreathingExerciseRowPresentation(id: 1, title: "Mindful breathing exercise".localized),
            BreathingExerciseRowPresentation(id: 2, title: "Diaphragmatic breathing exercise".localized),
        ]
    }

    // MARK: - Navigation

    func openBack() {
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    func openExercise(at id: Int) {
        guard let host = hostViewController else { return }

        switch id {
        case 0:
            BreathingTechniqueType1Navigation.push(from: host)
        case 1:
            MindfulBreathingNavigation.push(from: host)
        case 2:
            DiaphragmaticBreathingNavigation.push(from: host)
        default:
            break
        }
    }

    #if DEBUG
    func applyPreviewState() {
        reloadLocalizedStrings()
    }
    #endif
}

// MARK: - Navigation

enum BreathingTechniqueNavigation {

    static func push(from host: UIViewController, animated: Bool = true) {
        guard let nav = host.navigationController else { return }
        let breathingHost = BreathingTechniqueHostingController()
        nav.pushViewController(breathingHost, animated: animated)
    }
}
