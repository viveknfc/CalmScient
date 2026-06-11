//
//  ConSub5ViewModel.swift
//  Calmscient
//
//  State and navigation for Alcohol use disorder (AUD) (parity with `ConSub5VC`).
//
//  Vivek
//  25 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class ConSub5ViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var content = ConSub5ContentPresentation(
        headerTitle: "",
        bodyText: ""
    )

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
        content = ConSub5Presentation.buildLocalizedContent()
    }

    func openBack() {
        navigationController?.popViewController(animated: true)
    }

    func completeTapped() {
        openBack()
    }

    #if DEBUG
    func applyPreviewState() {
        reloadLocalizedStrings()
    }
    #endif
}

// MARK: - Navigation

@available(iOS 16.0, *)
enum ConSub5Navigation {

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

        let consequenceSubHost = ConSub5HostingController()
        consequenceSubHost.viewModel.configure(navigationTitle: navigationTitle)
        nav.pushViewController(consequenceSubHost, animated: animated)
    }
}
