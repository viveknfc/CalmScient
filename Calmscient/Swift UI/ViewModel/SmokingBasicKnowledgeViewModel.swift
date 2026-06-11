//
//  SmokingBasicKnowledgeViewModel.swift
//  Calmscient
//
//  State, API, and navigation for the Smoking Basic Knowledge index (parity with `SmokingBasicVc`).
//
//  Vivek
//  26 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class SmokingBasicKnowledgeViewModel: ObservableObject {

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
        fetchSmokingBasicKnowledgeIndex()
    }

    func reloadLocalizedStrings() {
        navigationChromeTitle = "Basic Knowledge".localized
        completeButtonTitle = "Complete".localized
    }

    func openBack() {
        navigationController?.popViewController(animated: true)
    }

    func completeTapped() {
        openBack()
    }

    func openRow(_ row: BasicKnowledgeRowPresentation) {
        guard let host = hostViewController else { return }

        let backItem = UIBarButtonItem()
        backItem.title = ""
        host.navigationItem.backBarButtonItem = backItem

        let screenTitle = navigationChromeTitle

        switch row.listIndex {
        case 0:
            TobaccoNavigation.push(from: host, sectionId: row.sectionId, navigationTitle: screenTitle)
        case 1:
            VapingNavigation.push(from: host, sectionId: row.sectionId, navigationTitle: screenTitle)
        case 2:
            SmokingRelaxNavigation.push(from: host, sectionId: row.sectionId, navigationTitle: screenTitle)
        case 3:
            ChallengingToQuitNavigation.push(
                from: host,
                sectionId: row.sectionId,
                navigationTitle: screenTitle
            )
            return
        case 4:
            SmokingAffectMentalHealthNavigation.push(
                from: host,
                sectionId: row.sectionId,
                navigationTitle: screenTitle
            )
            return
        case 5:
            MySmokingHabitNavigation.push(
                from: host,
                sectionId: row.sectionId,
                navigationTitle: screenTitle
            )
            return
        default:
            break
        }
    }

    // MARK: - API

    func fetchSmokingBasicKnowledgeIndex() {
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken,
              let host = hostViewController else {
            return
        }

        isLoading = true
        anchorView?.showToastActivity()

        let params: [String: Any] = [
            "patientId": userInfo.patientID,
            "clientId": userInfo.clientID,
        ]

        APIService.SBasicKQAPICalling(
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
enum SmokingBasicKnowledgeNavigation {

    static func push(from host: UIViewController, animated: Bool = true) {
        guard let nav = host.navigationController else { return }

        let backItem = UIBarButtonItem()
        backItem.title = ""
        host.navigationItem.backBarButtonItem = backItem

        let smokingBasicHost = SmokingBasicKnowledgeHostingController()
        nav.pushViewController(smokingBasicHost, animated: animated)
    }
}
