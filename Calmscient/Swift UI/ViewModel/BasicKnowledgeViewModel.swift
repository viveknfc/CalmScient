//
//  BasicKnowledgeViewModel.swift
//  Calmscient
//
//  State, API, and navigation for the Basic Knowledge index (parity with `Basicknowledge`).
//
//  Vivek
//  21 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class BasicKnowledgeViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var rows: [BasicKnowledgeRowPresentation] = []
    @Published private(set) var isLoading = false

    private(set) var navigationChromeTitle: String = ""
    private(set) var completeButtonTitle: String = ""

    private var anchorView: UIView? { hostViewController?.view }

    private var navigationController: UINavigationController? {
        hostViewController?.navigationController
    }

    private var tabBarController: UITabBarController? {
        hostViewController?.tabBarController
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = false
        fetchBasicKnowledgeIndex()
    }

    func reloadLocalizedStrings() {
        navigationChromeTitle = "Basic Knowledge".localized
        completeButtonTitle = "Complete".localized
    }

    func openBack() {
        guard let host = hostViewController else { return }
        TakingControlIndexNavigation.push(from: host, initialSegment: 0)
    }

    func completeTapped() {
        openBack()
    }

    func openRow(_ row: BasicKnowledgeRowPresentation) {
        guard let host = hostViewController,
              let nav = host.navigationController else {
            return
        }

        let backItem = UIBarButtonItem()
        backItem.title = ""
        host.navigationItem.backBarButtonItem = backItem

        let screenTitle = navigationChromeTitle

        switch row.listIndex {
        case 0:
            BasicStandardDrinkNavigation.push(
                from: host,
                sectionId: row.sectionId,
                navigationTitle: screenTitle
            )
        case 1:
            USGuideLineForDrinkingNavigation.push(
                from: host,
                sectionId: row.sectionId,
                navigationTitle: screenTitle
            )
        case 2:
            ModerationNavigation.push(
                from: host,
                sectionId: row.sectionId,
                navigationTitle: screenTitle
            )
        case 3:
            BasicKnowledgeVideoNavigation.push(
                from: host,
                sectionId: row.sectionId,
                navigationTitle: screenTitle
            )
        case 4:
            ConsequenceNavigation.push(
                from: host,
                sectionId: row.sectionId,
                navigationTitle: screenTitle
            )
        case 5:
            HoldYourLiquorNavigation.push(
                from: host,
                sectionId: row.sectionId,
                navigationTitle: screenTitle
            )
        case 6:
            MyDrinkingHabitNavigation.push(
                from: host,
                sectionId: row.sectionId,
                navigationTitle: screenTitle
            )
        default:
            break
        }
    }

    // MARK: - API

    func fetchBasicKnowledgeIndex() {
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken,
              let host = hostViewController else {
            return
        }

        isLoading = true
        anchorView?.showToastActivity()

        let params: [String: Any] = [
            "plId": userInfo.patientLocationID,
            "patientId": userInfo.patientID,
            "clientId": userInfo.clientID,
            "assessmentId": 1,
        ]

        APIService.DBasicKQAPICalling(
            host,
            params: params,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleFetchResponse(response)
            }
        }
    }

    private func handleFetchResponse(_ response: AnyObject) {
        isLoading = false
        anchorView?.hideToastActivity()

        guard let responseDict = response as? [String: Any],
              let indexArray = responseDict["index"] as? [[String: Any]] else {
            return
        }

        rows = BasicKnowledgeRowPresentation.rows(from: indexArray)
    }

    #if DEBUG
    func applyPreviewState(rows: [BasicKnowledgeRowPresentation]) {
        reloadLocalizedStrings()
        self.rows = rows
        isLoading = false
    }
    #endif
}

// MARK: - Navigation

@available(iOS 16.0, *)
enum BasicKnowledgeNavigation {

    static func push(from host: UIViewController, animated: Bool = true) {
        guard let nav = host.navigationController else { return }

        let backItem = UIBarButtonItem()
        backItem.title = ""
        host.navigationItem.backBarButtonItem = backItem

        let basicKnowledgeHost = BasicKnowledgeHostingController()
        nav.pushViewController(basicKnowledgeHost, animated: animated)
    }
}
