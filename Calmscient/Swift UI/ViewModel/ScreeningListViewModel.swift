//
//  ScreeningListViewModel.swift
//  Calmscient
//
//  State, API, and navigation for screenings list (parity with legacy `ScreeningListVC`).
//
//  Vivek
//  15 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class ScreeningListViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    // MARK: - SwiftUI navigation
    //
    // Set by `HomeTabView` when this screen is shown inside the Home `NavigationStack`.
    // While nil, every call below falls through to the existing UIKit push/pop, which is
    // what the still-UIKit Discovery tab uses when it pushes into these screens.
    var onOpenRoute: ((HomeRoute) -> Void)?
    var onClose: (() -> Void)?
    var onCloseToRoot: (() -> Void)?

    var isComingFromParticularVC = false
    var isComingFromParticularVC1 = false

    @Published private(set) var rows: [ScreeningRowPresentation] = []
    @Published private(set) var isLoading = false

    @Published private(set) var navigationChromeTitle: String = ""
    private(set) var headerTitle: String = ""
    private(set) var headerSubtitle: String = ""
    private(set) var viewHistoryTitle: String = ""
    private(set) var takeScreeningTitle: String = ""

    /// Falls back to the key window so this screen still shows toasts when it is
    /// presented without a `hostViewController` (SwiftUI-navigated Home tab).
    private var anchorView: UIView? { Toast.resolvedAnchor(hostViewController?.view) }

    /// Seeds the localized chrome up front so the navigation title is correct on the
    /// very first SwiftUI body evaluation (the UIKit host used to set it in `viewWillAppear`).
    init() {
        reloadLocalizedStrings()
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
        fetchScreenings()
    }

    func reloadLocalizedStrings() {
        navigationChromeTitle = "Screenings".localized
        headerTitle = AppHelper.getLocalizeString(str: "Please complete all of the following screenings")
        headerSubtitle = AppHelper.getLocalizeString(
            str: "Even if you feel they may not apply to you. These assessments helps us better understand your overall wellbeing."
        )
        viewHistoryTitle = AppHelper.getLocalizeString(str: "View history")
        takeScreeningTitle = AppHelper.getLocalizeString(str: "Take the screening")
    }

    // MARK: - Navigation

    func openBack() {
        if let onOpenRoute {
            if isComingFromParticularVC {
                onOpenRoute(.takingControlIndex(initialSegment: 0))
            } else if isComingFromParticularVC1 {
                onOpenRoute(.takingControlIndex(initialSegment: 1))
            } else {
                onOpenRoute(.userMedicalRecords)
            }
            return
        }

        guard let nav = hostViewController?.navigationController else { return }

        if isComingFromParticularVC {
            if let host = hostViewController {
                TakingControlIndexNavigation.push(from: host, initialSegment: 0)
            }
            return
        }

        if isComingFromParticularVC1 {
            if let host = hostViewController {
                TakingControlIndexNavigation.push(from: host, initialSegment: 1)
            }
            return
        }

        nav.pushViewController(UserMedicalRecordsHostingController(), animated: true)
    }

    func openHistory(for row: ScreeningRowPresentation) {
        if let onOpenRoute {
            onOpenRoute(.screeningHistory(RouteBox(row.screening)))
            return
        }
        guard let nav = hostViewController?.navigationController else { return }
        let host = HistoryHostingController()
        host.configure(selectedScreening: row.screening)
        nav.pushViewController(host, animated: true)
    }

    func openScreeningQuestions(for row: ScreeningRowPresentation) {
        if let onOpenRoute {
            onOpenRoute(.screeningQuestions(
                RouteBox(row.screening),
                fromParticular: isComingFromParticularVC,
                fromParticular1: isComingFromParticularVC1
            ))
            return
        }
        guard let nav = hostViewController?.navigationController else { return }
        let host = ScreeningQuestionsHostingController()
        host.configure(selectedScreening: row.screening) { [weak self] submitted in
            guard let submitted else { return }
            self?.openScreeningResult(submitted)
        }
        nav.pushViewController(host, animated: true)
    }

    private func openScreeningResult(_ screening: Screening) {
        guard let nav = hostViewController?.navigationController else { return }
        let host = ScreeningResultHostingController()
        host.configure(
            selectedScreening: screening,
            isComingFromParticularVC: isComingFromParticularVC,
            isComingFromParticularVC1: isComingFromParticularVC1
        )
        nav.pushViewController(host, animated: true)
    }

    // MARK: - API

    func fetchScreenings() {
        guard let loginResponse = ApplicationSharedInfo.shared.loginResponse,
              let host = hostViewController,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }

        isLoading = true
        rows = []
        anchorView?.showToastActivity()

        let params: [String: Any] = [
            "patientId": loginResponse.patientID,
            "clientId": loginResponse.clientID,
            "patientLocationId": loginResponse.patientLocationID,
        ]

        APIService.screeningListAssessmentrIdAPICalling(
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
              let decoded = try? JSONDecoder().decode(ScreeningResponse.self, from: data) else {
            anchorView?.showToast(message: "An Unknown error occured. Please check with Admin")
            return
        }

        if decoded.statusResponse.responseCode != 200 {
            anchorView?.showToast(message: decoded.statusResponse.responseMessage)
            return
        }

        rows = decoded.screeningList.map { ScreeningRowPresentation(screening: $0) }
    }

    #if DEBUG
    func applyPreviewState(rows: [ScreeningRowPresentation]) {
        reloadLocalizedStrings()
        self.rows = rows
    }
    #endif
}
