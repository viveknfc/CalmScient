//
//  TobaccoFreeViewModel.swift
//  Calmscient
//
//  State and navigation for tobacco-free screen (parity with `TobaccoFreeVC`).
//
//  Vivek
//  26 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class TobaccoFreeViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var content = SmokingEducationContentPresentation(
        headerTitle: "",
        bodyParagraphs: []
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
        content = TobaccoFreePresentation.buildLocalizedContent()
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
enum TobaccoFreeNavigation {

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

        let tobaccoFreeHost = TobaccoFreeHostingController()
        tobaccoFreeHost.viewModel.configure(navigationTitle: navigationTitle)
        nav.pushViewController(tobaccoFreeHost, animated: animated)
    }
}
