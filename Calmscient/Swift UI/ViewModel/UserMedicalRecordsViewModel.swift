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
        guard let nav = hostViewController?.navigationController else { return }
        let homeRoot = HomeDashboardHostingController()
        nav.pushViewController(homeRoot, animated: true)
    }

    func openProfile() {
        guard let nav = hostViewController?.navigationController else { return }
        let profile = UserProfileHostingController()
        profile.shouldPopBack = true
        UserDefaults.standard.removeObject(forKey: "shouldPopToDis")
        nav.pushViewController(profile, animated: true)
    }

    func openRow(at index: Int) {
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
