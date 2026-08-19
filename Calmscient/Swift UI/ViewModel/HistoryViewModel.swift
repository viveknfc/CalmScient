//
//  HistoryViewModel.swift
//  Calmscient
//
//  State, API, and navigation for screening history (parity with legacy `HistoryVC`).
//
//  Vivek
//  15 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class HistoryViewModel: ObservableObject {

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

    @Published private(set) var screeningTitle: String = ""
    @Published private(set) var rows: [HistoryRowPresentation] = []
    @Published private(set) var isLoading = false

    @Published private(set) var navigationChromeTitle: String = ""

    /// Falls back to the key window so this screen still shows toasts when it is
    /// presented without a `hostViewController` (SwiftUI-navigated Home tab).
    private var anchorView: UIView? { Toast.resolvedAnchor(hostViewController?.view) }

    func configure(selectedScreening: Screening) {
        self.selectedScreening = selectedScreening
        screeningTitle = selectedScreening.screeningType
    }

    /// Seeds the localized chrome up front so the navigation title is correct on the
    /// very first SwiftUI body evaluation (the UIKit host used to set it in `viewWillAppear`).
    init() {
        reloadLocalizedStrings()
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
        fetchHistory()
    }

    func reloadLocalizedStrings() {
        navigationChromeTitle = "History".localized
    }

    // MARK: - Navigation

    func openBack() {
        if let onClose {
            onClose()
            return
        }
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    // MARK: - API

    func fetchHistory() {
        guard let screening = selectedScreening,
              let loginResponse = ApplicationSharedInfo.shared.loginResponse,
              let host = hostViewController,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }

        isLoading = true
        rows = []
        anchorView?.showToastActivity()

        let params: [String: Any] = [
            "screeningId": screening.screeningID,
            "assessmentId": screening.assessmentID,
            "patientLocationId": loginResponse.patientLocationID,
            "patientId": loginResponse.patientID,
            "clientId": loginResponse.clientID,
        ]

        APIService.screeningHistoryAPICalling(
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
              let decoded = try? JSONDecoder().decode(ScreeningHistoryResponse.self, from: data) else {
            anchorView?.showToast(message: "An Unknown error occured. Please check with Admin")
            return
        }

        if decoded.statusResponse.responseCode != 200 {
            anchorView?.showToast(message: decoded.statusResponse.responseMessage)
            return
        }

        rows = decoded.screeningHistory.map { HistoryRowPresentation(history: $0) }
    }

    #if DEBUG
    func applyPreviewState(
        screeningTitle: String,
        rows: [HistoryRowPresentation]
    ) {
        reloadLocalizedStrings()
        self.screeningTitle = screeningTitle
        self.rows = rows
    }
    #endif
}
