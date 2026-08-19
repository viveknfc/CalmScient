//
//  ScreeningResultViewModel.swift
//  Calmscient
//
//  State, API, and navigation for screening results (parity with legacy `ScreeningResultVC`).
//
//  Vivek
//  15 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class ScreeningResultViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    // MARK: - SwiftUI navigation
    //
    // Set by `HomeTabView` when this screen is shown inside the Home `NavigationStack`.
    // While nil, every call below falls through to the existing UIKit push/pop, which is
    // what the still-UIKit Discovery tab uses when it pushes into these screens.
    var onOpenRoute: ((HomeRoute) -> Void)?
    var onClose: (() -> Void)?
    var onCloseToRoot: (() -> Void)?

    private(set) var selectedScreening: Screening?

    var isComingFromParticularVC = false
    var isComingFromParticularVC1 = false
    var isComingFromParticularVC2 = false

    @Published private(set) var result: ScreeningResultPresentation?
    @Published private(set) var isLoading = false
    @Published var showsMoreInfo = false

    @Published private(set) var navigationChromeTitle: String = ""
    private(set) var remindMeTitle: String = ""
    private(set) var remindOptionTitle: String = ""
    private(set) var scoreMarkedTitle: String = ""
    private(set) var totalScoreTitle: String = ""
    private(set) var needToTalkButtonTitle: String = ""

    /// Falls back to the key window so this screen still shows toasts when it is
    /// presented without a `hostViewController` (SwiftUI-navigated Home tab).
    private var anchorView: UIView? { Toast.resolvedAnchor(hostViewController?.view) }

    func configure(selectedScreening: Screening) {
        self.selectedScreening = selectedScreening
    }

    /// Seeds the localized chrome up front so the navigation title is correct on the
    /// very first SwiftUI body evaluation (the UIKit host used to set it in `viewWillAppear`).
    init() {
        reloadLocalizedStrings()
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
        fetchResults()
    }

    func reloadLocalizedStrings() {
        navigationChromeTitle = "Your results".localized
        remindMeTitle = AppHelper.getLocalizeString(str: "Remind me")
        remindOptionTitle = "Weekly".localized
        scoreMarkedTitle = AppHelper.getLocalizeString(str: "Score\nmarked")
        totalScoreTitle = AppHelper.getLocalizeString(str: "Total score")
        needToTalkButtonTitle = "Need to talk with someone?".localized
    }

    // MARK: - Navigation

    func openBack() {
        if let onOpenRoute {
            if isComingFromParticularVC2 {
                onOpenRoute(.takingControlIntroSecond)
            } else {
                onOpenRoute(.screeningList)
            }
            return
        }

        guard let nav = hostViewController?.navigationController else { return }

        if isComingFromParticularVC {
            let host = ScreeningListHostingController()
            host.configure(isComingFromParticularVC: true)
            nav.pushViewController(host, animated: true)
            return
        }

        if isComingFromParticularVC1 {
            let host = ScreeningListHostingController()
            host.configure(isComingFromParticularVC1: true)
            nav.pushViewController(host, animated: true)
            return
        }

        if isComingFromParticularVC2 {
            if #available(iOS 16.0, *) {
                let host = TakingControlIntroSecondHostingController()
                host.configure(auditData: [], dastData: [])
                nav.pushViewController(host, animated: true)
            }
            return
        }

        let host = ScreeningListHostingController()
        nav.pushViewController(host, animated: true)
    }

    func openNeedToTalk() {
        if let onOpenRoute {
            onOpenRoute(.needToTalk)
            return
        }
        guard let host = hostViewController else { return }
        NeedToTalkNavigation.push(from: host)
    }

    func presentMoreInfo() {
        showsMoreInfo = true
    }

    func dismissMoreInfo() {
        showsMoreInfo = false
    }

    // MARK: - API

    func fetchResults() {
        guard let screening = selectedScreening,
              let loginResponse = ApplicationSharedInfo.shared.loginResponse,
              let host = hostViewController,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }

        isLoading = true
        result = nil
        anchorView?.showToastActivity()

        let params: [String: Any] = [
            "screeningId": screening.screeningID,
            "assessmentId": screening.assessmentID,
            "patientLocationId": loginResponse.patientLocationID,
            "patientId": loginResponse.patientID,
            "clientId": loginResponse.clientID,
        ]

        APIService.screeningResultsAPICalling(
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

        if let errorMessage = response as? String, errorMessage.hasPrefix("Error:") {
            anchorView?.showToast(message: errorMessage.replacingOccurrences(of: "Error: ", with: ""))
            return
        }

        guard let json = response as? [String: Any],
              let data = try? JSONSerialization.data(withJSONObject: json),
              let decoded = try? JSONDecoder().decode(ScreeningSuccessResponse.self, from: data) else {
            anchorView?.showToast(message: "An Unknown error occured. Please check with Admin")
            return
        }

        if decoded.statusResponse.responseCode != 200 {
            anchorView?.showToast(message: decoded.statusResponse.responseMessage)
            return
        }

        result = ScreeningResultPresentation(results: decoded.screeningResults)
    }

    #if DEBUG
    func applyPreviewState(result: ScreeningResultPresentation) {
        reloadLocalizedStrings()
        self.result = result
    }
    #endif
}
