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

    private(set) var selectedScreening: Screening?

    var isComingFromParticularVC = false
    var isComingFromParticularVC1 = false
    var isComingFromParticularVC2 = false

    @Published private(set) var result: ScreeningResultPresentation?
    @Published private(set) var isLoading = false
    @Published var showsMoreInfo = false

    private(set) var navigationChromeTitle: String = ""
    private(set) var remindMeTitle: String = ""
    private(set) var remindOptionTitle: String = ""
    private(set) var scoreMarkedTitle: String = ""
    private(set) var totalScoreTitle: String = ""
    private(set) var needToTalkButtonTitle: String = ""

    private var anchorView: UIView? { hostViewController?.view }

    func configure(selectedScreening: Screening) {
        self.selectedScreening = selectedScreening
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
        guard let nav = hostViewController?.navigationController else { return }

        if isComingFromParticularVC {
            let next = UIStoryboard(name: "ScreeningListVC", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "ScreeningListVC") as? ScreeningListVC
            vc?.isComingFromParticularVC = true
            nav.pushViewController(vc!, animated: true)
            return
        }

        if isComingFromParticularVC1 {
            let next = UIStoryboard(name: "ScreeningListVC", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "ScreeningListVC") as? ScreeningListVC
            vc?.isComingFromParticularVC1 = true
            nav.pushViewController(vc!, animated: true)
            return
        }

        if isComingFromParticularVC2 {
            if #available(iOS 16.0, *) {
                let host = TakingControlIntroSecondHostingController()
                host.configure(auditData: [], dastData: [])
                nav.pushViewController(host, animated: true)
            } else {
                let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
                if let vc = next.instantiateViewController(withIdentifier: "IntroSecondPageVC") as? IntroSecondPageVC {
                    nav.pushViewController(vc, animated: true)
                }
            }
            return
        }

        let next = UIStoryboard(name: "ScreeningListVC", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "ScreeningListVC") as? ScreeningListVC
        nav.pushViewController(vc!, animated: true)
    }

    func openNeedToTalk() {
        guard let nav = hostViewController?.navigationController else { return }
        let next = UIStoryboard(name: "NeedToTalkViewController", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "NeedToTalkViewController") as? NeedToTalkViewController
        vc?.title = "Emergency resource"
        guard let vc else { return }
        nav.pushViewController(vc, animated: true)
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
