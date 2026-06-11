//
//  ConsequenceViewModel.swift
//  Calmscient
//
//  State, API, and navigation for the consequences index (parity with `ConsequenceVC`).
//
//  Vivek
//  25 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class ConsequenceViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var content = ConsequenceContentPresentation(
        headerTitle: "",
        introBodyText: "",
        seeSomeLineText: "",
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
        content = ConsequencePresentation.buildLocalizedContent()
    }

    func openBack() {
        navigationController?.popViewController(animated: true)
    }

    func openTopic(_ row: ConsequenceTopicRowPresentation) {
        guard let host = hostViewController else { return }

        switch row.storyboardIdentifier {
        case "ConSub1VC":
            ConSub1Navigation.push(from: host, navigationTitle: navigationChromeTitle)
            return
        case "ConSub2VC":
            ConSub2Navigation.push(from: host, navigationTitle: navigationChromeTitle)
            return
        case "ConSub3VC":
            ConSub3Navigation.push(from: host, navigationTitle: navigationChromeTitle)
            return
        case "ConSub4VC":
            ConSub4Navigation.push(from: host, navigationTitle: navigationChromeTitle)
            return
        case "ConSub5VC":
            ConSub5Navigation.push(from: host, navigationTitle: navigationChromeTitle)
            return
        default:
            break
        }

        guard let nav = host.navigationController else { return }

        let backItem = UIBarButtonItem()
        backItem.title = ""
        host.navigationItem.backBarButtonItem = backItem

        let storyboard = UIStoryboard(name: "Taking Control Index", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: row.storyboardIdentifier) as? UIViewController else {
            return
        }

        vc.title = navigationChromeTitle
        nav.pushViewController(vc, animated: true)
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

        APIService.DUpdateBasicKAPICalling(
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
            print("ConsequenceViewModel: unsupported complete response — \(type(of: response))")
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
enum ConsequenceNavigation {

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

        let consequenceHost = ConsequenceHostingController()
        consequenceHost.viewModel.configure(sectionId: sectionId, navigationTitle: navigationTitle)
        nav.pushViewController(consequenceHost, animated: animated)
    }
}
