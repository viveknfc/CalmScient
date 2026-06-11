//
//  ConSub1ViewModel.swift
//  Calmscient
//
//  State and navigation for Fatalities and injuries (parity with `ConSub1VC`).
//
//  Vivek
//  25 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class ConSub1ViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var content = ConSub1ContentPresentation(
        headerTitle: "",
        introText: "",
        factorIntroText: "",
        bulletItems: []
    )
    @Published private(set) var alertContent = ConSub1AlertPresentation(title: "", bodyText: "")
    @Published var isDidYouKnowAlertPresented = false

    private(set) var navigationChromeTitle: String = ""
    private(set) var completeButtonTitle: String = ""

    private var navigationController: UINavigationController? {
        hostViewController?.navigationController
    }

    private var tabBarController: UITabBarController? {
        hostViewController?.tabBarController
    }

    func configure(navigationTitle: String? = nil) {
        if let navigationTitle, !navigationTitle.isEmpty {
            navigationChromeTitle = navigationTitle
        }
    }

    func onHostViewDidLoad() {
        reloadLocalizedStrings()
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = false
    }

    func reloadLocalizedStrings() {
        if navigationChromeTitle.isEmpty {
            navigationChromeTitle = "Basic Knowledge".localized
        }
        completeButtonTitle = "Complete".localized
        content = ConSub1Presentation.buildLocalizedContent()
        alertContent = ConSub1Presentation.buildLocalizedAlert()
    }

    func openBack() {
        navigationController?.popViewController(animated: true)
    }

    func spotlightTapped() {
        isDidYouKnowAlertPresented = true
    }

    func dismissDidYouKnowAlert() {
        isDidYouKnowAlertPresented = false
    }

    func completeTapped() {
        openBack()
    }

    #if DEBUG
    func applyPreviewState() {
        reloadLocalizedStrings()
        isDidYouKnowAlertPresented = false
    }
    #endif
}

// MARK: - Navigation

@available(iOS 16.0, *)
enum ConSub1Navigation {

    @MainActor
    static func push(
        from host: UIViewController,
        navigationTitle: String? = nil,
        animated: Bool = true
    ) {
        guard let nav = host.navigationController else { return }

        let backItem = UIBarButtonItem()
        backItem.title = ""
        host.navigationItem.backBarButtonItem = backItem

        let consequenceSubHost = ConSub1HostingController()
        consequenceSubHost.viewModel.configure(navigationTitle: navigationTitle)
        nav.pushViewController(consequenceSubHost, animated: animated)
    }
}
