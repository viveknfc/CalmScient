//
//  TakingControlIntroSecondViewModel.swift
//  Calmscient
//
//  State and navigation for the Taking Control intro second screen (AUDIT / DAST-10 chooser).
//  Parity with `IntroSecondPageVC`.
//
//  Vivek
//  20 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class TakingControlIntroSecondViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var screenTitle: String = ""
    @Published private(set) var instructionText: String = ""
    @Published private(set) var auditTitle: String = ""
    @Published private(set) var auditSubtitle: String = ""
    @Published private(set) var dastTitle: String = ""
    @Published private(set) var dastSubtitle: String = ""
    @Published private(set) var isLoading = false

    private(set) var auditData: [Screening] = []
    private(set) var dastData: [Screening] = []

    private var didAttemptScreeningFetch = false
    private var anchorView: UIView? { hostViewController?.view }

    init() {
        reloadLocalizedStrings()
    }

    func applyScreenings(audit: [Screening], dast: [Screening]) {
        auditData = audit
        dastData = dast
    }

    func reloadLocalizedStrings() {
        screenTitle = TakingControlIntroSecondLocalization.takingControlTitle.localized
        instructionText = TakingControlIntroSecondLocalization.introInstruction.localized
        auditTitle = TakingControlIntroSecondLocalization.auditTitle.localized
        auditSubtitle = TakingControlIntroSecondLocalization.auditSubtitle.localized
        dastTitle = TakingControlIntroSecondLocalization.dastTitle.localized
        dastSubtitle = TakingControlIntroSecondLocalization.dastSubtitle.localized
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
        ensureScreeningPayload()
    }

    func openBack() {
        guard let host = hostViewController else { return }
        TakingControlIndexNavigation.push(from: host, initialSegment: 0)
    }

    func openPreviousIntroPage() {
        guard let host = hostViewController else { return }
        TakingControlIntroNavigation.push(from: host, animated: true)
    }

    func openNextPage() {
        guard let nav = hostViewController?.navigationController else { return }
        let last = TakingIntroLastHostingController()
        nav.pushViewController(last, animated: true)
    }

    func openAuditFlow() {
        openScreeningFlow(screenings: auditData)
    }

    func openDastFlow() {
        openScreeningFlow(screenings: dastData)
    }

    // MARK: - Private

    private func openScreeningFlow(screenings: [Screening]) {
        guard let nav = hostViewController?.navigationController,
              let screening = screenings.first else {
            return
        }

        let questionsHost = ScreeningQuestionsHostingController()
        questionsHost.configure(selectedScreening: screening) { [weak self] updated in
            guard let self,
                  let innerNav = self.hostViewController?.navigationController,
                  let updated else { return }

            let resultHost = ScreeningResultHostingController()
            resultHost.configure(selectedScreening: updated, isComingFromParticularVC2: true)
            innerNav.pushViewController(resultHost, animated: true)
        }
        nav.pushViewController(questionsHost, animated: true)
    }

    private func ensureScreeningPayload() {
        guard !auditData.isEmpty, !dastData.isEmpty else {
            fetchScreeningListIfNeeded()
            return
        }
    }

    private func fetchScreeningListIfNeeded() {
        guard !didAttemptScreeningFetch else { return }
        didAttemptScreeningFetch = true

        guard let loginResponse = ApplicationSharedInfo.shared.loginResponse,
              let host = hostViewController,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }

        isLoading = true
        anchorView?.showToastActivity()

        let params: [String: Any] = [
            "patientId": loginResponse.patientID,
            "patientLocationId": loginResponse.patientLocationID,
            "clientId": loginResponse.clientID,
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
                self?.handleScreeningListResponse(response)
            }
        }
    }

    private func handleScreeningListResponse(_ response: AnyObject) {
        isLoading = false
        anchorView?.hideToastActivity()

        if let responseString = response as? String, responseString.hasPrefix("Error:") {
            anchorView?.showToast(message: responseString.replacingOccurrences(of: "Error: ", with: ""))
            return
        }

        guard let json = response as? [String: Any],
              let data = try? JSONSerialization.data(withJSONObject: json),
              let decoded = try? JSONDecoder().decode(ScreeningResponse.self, from: data) else {
            return
        }

        let all = decoded.screeningList
        auditData = all.filter { $0.screeningType.uppercased() == "AUDIT" }
        dastData = all.filter { $0.screeningType.uppercased() == "DAST-10" }
    }

    #if DEBUG
    func applyPreviewState(
        audit: [Screening] = [],
        dast: [Screening] = []
    ) {
        reloadLocalizedStrings()
        auditData = audit
        dastData = dast
        didAttemptScreeningFetch = true
    }
    #endif
}
