//
//  ProfilePrivacyViewModel.swift
//  Calmscient
//
//  Vivek
//  14 May 2026
//
//  MVVM parity with legacy `ProfilePrivacyViewController` (fetch + toggle consent APIs).
//

import Foundation
import SwiftUI
import UIKit

@MainActor
final class ProfilePrivacyViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published var consentItems: [PatientPrivacyConsentItem] = []
    @Published private(set) var isLoading: Bool = false

    var privacyTitle: String {
        AppHelper.getLocalizeString(str: "Privacy")
    }

    var privacyDescription: String {
        AppHelper.getLocalizeString(
            str: "Data from Calmscient can be transmitted to your doctor for clinical review purposes. Please indicate which data you allow to be shared with your doctor by selecting either Yes or No next to each data element below"
        )
    }

    private var anchorView: UIView? { hostViewController?.view }

    func onAppear() {
        loadPatientPrivacyIfPossible()
    }

    func close() {
        NotificationCenter.default.post(name: Notification.Name("RemoveDimmingView"), object: nil)
        hostViewController?.dismiss(animated: true)
    }

    func toggleConsent(at index: Int) {
        guard consentItems.indices.contains(index) else { return }
        guard NetworkMonitor.shared.isConnected else {
            NoInternetBanner.shared.show()
            return
        }
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken,
              let host = hostViewController else {
            return
        }

        var row = consentItems[index]
        let newFlag = row.consentFlag == 1 ? 0 : 1
        row.consentFlag = newFlag
        consentItems[index] = row

        anchorView?.showToastActivity()

        let params: [String: Any] = [
            "plId": userInfo.patientLocationID,
            "patientId": userInfo.patientID,
            "clientId": userInfo.clientID,
            "flag": newFlag,
            "consentListId": row.consentListId,
        ]

        APIService.updatePatientConsentAPICalling(
            host,
            params: params,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.anchorView?.hideToastActivity()
                if let json = response as? [String: Any],
                   let statusResponse = json["statusResponse"] as? [String: Any],
                   let responseCode = statusResponse["responseCode"] as? Int,
                   let responseMessage = statusResponse["responseMessage"] as? String,
                   let isUpdated = json["isUpdated"] as? Int {
                    print("Response Code: \(responseCode)")
                    print("Response Message: \(responseMessage)")
                    print("Is Updated: \(isUpdated)")
                } else if let errorMessage = response as? String {
                    print("Privacy update error: \(errorMessage)")
                }
            }
        }
    }

    private func loadPatientPrivacyIfPossible() {
        guard NetworkMonitor.shared.isConnected else {
            NoInternetBanner.shared.show()
            isLoading = false
            return
        }
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken,
              let host = hostViewController else {
            isLoading = false
            return
        }

        isLoading = true
        anchorView?.showToastActivity()

        let params: [String: Any] = [
            "plId": userInfo.patientLocationID,
            "patientId": userInfo.patientID,
            "clientId": userInfo.clientID,
        ]

        APIService.getPatientPrivacyAPICalling(
            host,
            params: params,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                guard let self else { return }
                self.anchorView?.hideToastActivity()
                self.isLoading = false

                if let errorMessage = response as? String, errorMessage.hasPrefix("Error:") {
                    print("Error: \(errorMessage)")
                    return
                }

                guard let json = response as? [String: Any],
                      let rawList = json["patientConsent"] as? [[String: Any]] else {
                    return
                }
                self.consentItems = Self.mapConsentList(rawList)
            }
        }
    }

    private static func mapConsentList(_ rawList: [[String: Any]]) -> [PatientPrivacyConsentItem] {
        rawList.compactMap { dict -> PatientPrivacyConsentItem? in
            guard let id = dict["consentListId"] as? Int,
                  let name = dict["consentListName"] as? String,
                  let flag = dict["consentFlag"] as? Int else {
                return nil
            }
            return PatientPrivacyConsentItem(consentListId: id, consentListName: name, consentFlag: flag)
        }
    }
}

#if DEBUG
extension ProfilePrivacyViewModel {
    static func previewFilled() -> ProfilePrivacyViewModel {
        let vm = ProfilePrivacyViewModel()
        vm.consentItems = [
            PatientPrivacyConsentItem(consentListId: 1, consentListName: "Journaling", consentFlag: 1),
            PatientPrivacyConsentItem(consentListId: 2, consentListName: "Course work", consentFlag: 1),
            PatientPrivacyConsentItem(consentListId: 3, consentListName: "Mood", consentFlag: 1),
        ]
        vm.isLoading = false
        return vm
    }
}
#endif
