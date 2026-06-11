//
//  ReadyToQuitViewModel.swift
//  Calmscient
//
//  State and navigation for ready-to-quit (parity with `ReadyToQuitVC`).
//
//  Vivek
//  26 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class ReadyToQuitViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var content = ReadyToQuitContentPresentation(
        headerTitle: "",
        bodyParagraphs: [],
        topicRows: []
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
        content = ReadyToQuitPresentation.buildLocalizedContent()
    }

    func openBack() {
        navigationController?.popViewController(animated: true)
    }

    func openTopic(_ row: ConsequenceTopicRowPresentation) {
        guard let host = hostViewController,
              let topic = row.quitSymptomTopic else { return }

        QuitSymptomModalViewModel.present(topic: topic, from: host)
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
enum ReadyToQuitNavigation {

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

        let readyHost = ReadyToQuitHostingController()
        readyHost.viewModel.configure(navigationTitle: navigationTitle)
        nav.pushViewController(readyHost, animated: animated)
    }
}
