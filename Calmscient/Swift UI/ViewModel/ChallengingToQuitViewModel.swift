//
//  ChallengingToQuitViewModel.swift
//  Calmscient
//
//  State, API, and navigation for challenging-to-quit index (parity with `ChallengingtoQuitVC`).
//
//  Vivek
//  26 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class ChallengingToQuitViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var content = ChallengingToQuitContentPresentation(
        headerTitle: "",
        bodyParagraphs: [],
        topicRows: []
    )
    @Published private(set) var isCompleting = false

    private(set) var navigationChromeTitle: String = ""
    private(set) var completeButtonTitle: String = ""

    private(set) var sectionId: Int = 0

    private var anchorView: UIView? { hostViewController?.view }

    private var navigationController: UINavigationController? {
        hostViewController?.navigationController
    }

    private var tabBarController: UITabBarController? {
        hostViewController?.tabBarController
    }

    func configure(sectionId: Int, navigationTitle: String? = nil) {
        self.sectionId = sectionId
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
        content = ChallengingToQuitPresentation.buildLocalizedContent()
    }

    func openBack() {
        navigationController?.popViewController(animated: true)
    }

    func openTopic(_ row: ConsequenceTopicRowPresentation) {
        guard let host = hostViewController else { return }

        let backItem = UIBarButtonItem()
        backItem.title = ""
        host.navigationItem.backBarButtonItem = backItem

        let screenTitle = navigationChromeTitle

        switch row.storyboardIdentifier {
        case "ThinkingAbtQuitingVC":
            ThinkingAboutQuittingNavigation.push(from: host, navigationTitle: screenTitle)
        case "ReadyToQuitVC":
            ReadyToQuitNavigation.push(from: host, navigationTitle: screenTitle)
        case "TryingToQuitVC":
            TryingToQuitNavigation.push(from: host, navigationTitle: screenTitle)
        case "TobaccoFreeVC":
            TobaccoFreeNavigation.push(from: host, navigationTitle: screenTitle)
        default:
            break
        }
    }

    func completeTapped() {
        guard let host = hostViewController,
              let userInfo = ApplicationSharedInfo.shared.loginResponse,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }

        isCompleting = true
        anchorView?.showToastActivity()

        let params: [String: Any] = [
            "isCompleted": 1,
            "patientId": userInfo.patientID,
            "sectionId": sectionId,
        ]

        APIService.SUpdateBasicKAPICalling(
            host,
            params: params,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleCompleteResponse(response)
            }
        }
    }

    private func handleCompleteResponse(_ response: AnyObject) {
        isCompleting = false
        anchorView?.hideToastActivity()

        guard response is [String: Any] else {
            print("ChallengingToQuitViewModel: unsupported complete response — \(type(of: response))")
            return
        }

        openBack()
    }

    #if DEBUG
    func applyPreviewState() {
        reloadLocalizedStrings()
        isCompleting = false
    }
    #endif
}

// MARK: - Navigation

@available(iOS 16.0, *)
enum ChallengingToQuitNavigation {

    @MainActor
    static func push(
        from host: UIViewController,
        sectionId: Int,
        navigationTitle: String? = nil,
        animated: Bool = true
    ) {
        guard let nav = host.navigationController else { return }

        let backItem = UIBarButtonItem()
        backItem.title = ""
        host.navigationItem.backBarButtonItem = backItem

        let challengingHost = ChallengingToQuitHostingController()
        challengingHost.viewModel.configure(sectionId: sectionId, navigationTitle: navigationTitle)
        nav.pushViewController(challengingHost, animated: animated)
    }
}
