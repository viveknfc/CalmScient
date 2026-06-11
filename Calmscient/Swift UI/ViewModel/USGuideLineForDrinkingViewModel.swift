//
//  USGuideLineForDrinkingViewModel.swift
//  Calmscient
//
//  State, API, and navigation for U.S. drinking guidelines (parity with `USGuideLineForDrinkingVC`).
//
//  Vivek
//  21 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class USGuideLineForDrinkingViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var sections: [USDrinkingGuidelineSectionPresentation] = []
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
        sections = USGuideLineForDrinkingPresentationBuilder.buildSections(
            usGuidelinesTitle: "What are the U.S. guidelines for drinking?".localized,
            dietarySubtitle: "us_guidelines_dietary_subheader".localized,
            menLabel: "us_guidelines_label_men".localized,
            womenLabel: "us_guidelines_label_women".localized,
            menStandard: "us_guidelines_men_standard".localized,
            womenStandard: "us_guidelines_women_standard".localized,
            whatIsPrefix: "us_guidelines_what_is_prefix".localized,
            alcoholMisuseAccent: "us_guidelines_alcohol_misuse_suffix".localized,
            niaaaHeavySubtitle: "us_guidelines_niaaa_heavy".localized,
            menHeavyLine1: "us_guidelines_men_heavy_line1".localized,
            menHeavyLine2: "us_guidelines_men_heavy_line2".localized,
            womenHeavyLine1: "us_guidelines_women_heavy_line1".localized,
            womenHeavyLine2: "us_guidelines_women_heavy_line2".localized,
            bingeAccent: "us_guidelines_binge_suffix".localized,
            niaaaBingeSubtitle: "us_guidelines_niaaa_binge".localized,
            menBingeLine1: "us_guidelines_men_binge_line1".localized,
            menBingeLine2: "us_guidelines_men_binge_line2".localized,
            womenBingeLine1: "us_guidelines_women_binge_line1".localized,
            womenBingeLine2: "us_guidelines_women_binge_line2".localized
        )
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
            print("USGuideLineForDrinkingViewModel: unsupported complete response — \(type(of: response))")
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
enum USGuideLineForDrinkingNavigation {

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

        let guidelinesHost = USGuideLineForDrinkingHostingController()
        guidelinesHost.viewModel.configure(sectionId: sectionId, navigationTitle: navigationTitle)
        nav.pushViewController(guidelinesHost, animated: animated)
    }
}
