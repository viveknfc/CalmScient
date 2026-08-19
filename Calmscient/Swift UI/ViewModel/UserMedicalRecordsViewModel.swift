//
//  UserMedicalRecordsViewModel.swift
//  Calmscient
//
//  State and navigation for the SwiftUI medical records hub (parity with `UserMedicalRecordsViewController`).
//
//  Vivek
//  14 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class UserMedicalRecordsViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    // MARK: - SwiftUI navigation
    //
    // Set by `HomeTabView` when this screen is shown inside the Home `NavigationStack`.
    // While nil, every call below falls through to the existing UIKit push/pop, which is
    // what the still-UIKit Discovery tab uses when it pushes into these screens.
    var onOpenRoute: ((HomeRoute) -> Void)?
    var onClose: (() -> Void)?
    var onCloseToRoot: (() -> Void)?

    @Published private(set) var screenTitle: String = ""
    @Published private(set) var rows: [(title: String, imageName: String)] = []

    init() {
        reloadLocalizedStrings()
    }

    func reloadLocalizedStrings() {
        screenTitle = "My medical records".localized
        rows = [
            ("Medications".localized, "Medications_Cell"),
            ("Upcoming medical appointments".localized, "MedicalAppointment_Cell"),
            ("Screenings".localized, "Screening_Cell"),
        ]
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
    }

    /// Matches legacy `backButtonOverrideAction`: push home dashboard onto the stack.
    func openBackToHome() {
        // SwiftUI Home tab: the dashboard is the stack root, so going back is a pop.
        // The UIKit path had no root to pop to and had to push a fresh dashboard.
        if let onClose {
            onClose()
            return
        }
        guard let nav = hostViewController?.navigationController else { return }
        let homeRoot = HomeDashboardHostingController()
        nav.pushViewController(homeRoot, animated: true)
    }

    func openProfile() {
        if let onOpenRoute {
            UserDefaults.standard.removeObject(forKey: "shouldPopToDis")
            onOpenRoute(.userProfile)
            return
        }
        guard let nav = hostViewController?.navigationController else { return }
        let profile = UserProfileHostingController()
        profile.shouldPopBack = true
        UserDefaults.standard.removeObject(forKey: "shouldPopToDis")
        nav.pushViewController(profile, animated: true)
    }

    func openRow(at index: Int) {
        if let onOpenRoute {
            switch index {
            case 0: onOpenRoute(.userMedications)
            case 1: onOpenRoute(.nextAppointments)
            case 2: onOpenRoute(.screeningList)
            default: break
            }
            return
        }
        guard let nav = hostViewController?.navigationController else { return }
        switch index {
        case 0:
            nav.pushViewController(UserMedicationsHostingController(), animated: true)
        case 1:
            nav.pushViewController(NextAppointmentsHostingController(), animated: true)
        case 2:
            nav.pushViewController(ScreeningListHostingController(), animated: true)
        default:
            break
        }
    }
}
