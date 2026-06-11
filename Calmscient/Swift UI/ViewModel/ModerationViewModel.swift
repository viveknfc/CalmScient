//
//  ModerationViewModel.swift
//  Calmscient
//
//  State, API, and navigation for the moderation screen (parity with `Moderation`).
//
//  Vivek
//  21 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class ModerationViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var content = ModerationContentPresentation(
        headerTitle: "",
        introText: "",
        bulletItems: [],
        bodyAttributedText: AttributedString()
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

        let bodyFont = LoginDesignSystem.Typography.lexendLight(size: 14)
        content = ModerationPresentation.buildLocalizedContent(bodyFont: bodyFont)
    }

    func openBack() {
        navigationController?.popViewController(animated: true)
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
            print("ModerationViewModel: unsupported complete response — \(type(of: response))")
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
enum ModerationNavigation {

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

        let moderationHost = ModerationHostingController()
        moderationHost.viewModel.configure(sectionId: sectionId, navigationTitle: navigationTitle)
        nav.pushViewController(moderationHost, animated: animated)
    }
}
