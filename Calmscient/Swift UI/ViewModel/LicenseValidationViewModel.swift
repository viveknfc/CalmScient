//
//  LicenseValidationViewModel.swift
//  Calmscient
//
//  Parity with UserRegistrationViewController: validateLicenseKey via APIService, alerts, then login root.
//
//  Vivek
//  14 May 2026
//
import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class LicenseValidationViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published var licenseKey: String = ""
    @Published private(set) var isSubmitting: Bool = false

    func submitLicense() {
        hostViewController?.view.endEditing(true)

        let trimmed = licenseKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            hostViewController?.showGeneralAlert(
                image: UIImage(named: "InfoIcon"),
                imageSize: CGSize(width: 40, height: 40),
                title: "Please enter the license key",
                okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                okAction: {},
                showDismissButton: false
            )
            return
        }

        isSubmitting = true
        anchorView?.showToastActivity()

        let params: [String: Any] = ["licenseKey": trimmed]
        APIService.validateLicenseKeyAPICalling(
            hostViewController,
            params: params,
            method: "POST",
            accessToken: "",
            acces: true,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                guard let self else { return }
                self.finishSubmitUI()
                self.handleValidateResponse(response)
            }
        }
    }

    // MARK: - Private

    private var anchorView: UIView? {
        hostViewController?.view
    }

    private func handleValidateResponse(_ response: AnyObject) {
        if response is String {
            if let responseString = response as? String {
                print("Response received from validate API calling is", responseString)
            }
            return
        }

        guard let tuple = LicenseValidationResponseParser.status(from: response) else {
            print("Invalid statusResponse format.")
            return
        }

        let responseCode = tuple.code
        let responseMessage = tuple.message

        if responseCode == 200 {
            let successContent = AppHelper.getLocalizeString(str: "license_key_verified_success_message")
            hostViewController?.showSuccessAlert(successContent: successContent, centreImage: nil, okButtonAction: { [weak self] in
                self?.navigateToLoginRoot()
            })
        } else {
            hostViewController?.showGeneralAlert(
                image: UIImage(named: "InfoIcon"),
                imageSize: CGSize(width: 40, height: 40),
                title: responseMessage,
                okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                okAction: { [weak self] in
                    self?.navigateToLoginRoot()
                },
                showDismissButton: false
            )
        }
    }

    private func navigateToLoginRoot() {
        let navC = LoginHostingController.loginNavigationRoot()
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            window.rootViewController = navC
            window.makeKeyAndVisible()
        }
    }

    private func finishSubmitUI() {
        isSubmitting = false
        anchorView?.hideToastActivity()
    }
}
