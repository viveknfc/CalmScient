//
//  UpdatePasswordViewModel.swift
//  Calmscient
//
//  Parity with UpdatePasswordVC: POST forgetPassword, validation, success → login root.
//
//  Vivek
//  14 May 2026
//
import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class UpdatePasswordViewModel: ObservableObject {

    let email: String

    weak var hostViewController: UIViewController?

    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""
    @Published var newPasswordVisible: Bool = false
    @Published var confirmPasswordVisible: Bool = false
    @Published private(set) var isSubmitting: Bool = false

    init(email: String) {
        self.email = email
    }

    func submit() {
        hostViewController?.view.endEditing(true)

        let trimmedNew = newPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConfirm = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedNew.isEmpty, !trimmedConfirm.isEmpty else {
            hostViewController?.showGeneralAlert(
                image: UIImage(named: "InfoIcon"),
                imageSize: CGSize(width: 60, height: 60),
                title: "Please fill in both new password and confirm password.",
                okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                okAction: {},
                showDismissButton: false
            )
            return
        }

        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?\":{}|<>])[A-Za-z\\d!@#$%^&*(),.?\":{}|<>]{8,}$"
        guard NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: trimmedNew) else {
            hostViewController?.showGeneralAlert(
                image: UIImage(named: "InfoIcon"),
                imageSize: CGSize(width: 60, height: 60),
                title: "Your password must be at least eight characters long and include at least one special character and one number.",
                okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                okAction: {},
                showDismissButton: false
            )
            return
        }

        guard trimmedNew == trimmedConfirm else {
            hostViewController?.showGeneralAlert(
                image: UIImage(named: "InfoIcon"),
                imageSize: CGSize(width: 60, height: 60),
                title: "New password and confirm password should match.",
                okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                okAction: {},
                showDismissButton: false
            )
            return
        }

        guard NetworkMonitor.shared.isConnected else {
            NoInternetBanner.shared.show()
            return
        }

        isSubmitting = true
        anchorView?.showToastActivity()

        performForgetPassword(emailId: email, newPassword: trimmedNew, confirmPassword: trimmedConfirm)
    }

    // MARK: - Private

    private var anchorView: UIView? {
        hostViewController?.view
    }

    private func finishSubmitUI() {
        isSubmitting = false
        anchorView?.hideToastActivity()
    }

    private func handleForgetPasswordResponse(_ response: AnyObject) {
        if let message = response as? String {
            if message.hasPrefix("Error: No Internet Connection") {
                return
            }
            print("UpdatePassword forgetPassword: \(message)")
            return
        }

        guard let responseDict = response as? [String: Any] else {
            print("Unsupported forgetPassword response type: \(type(of: response))")
            return
        }

        print(responseDict)
        hostViewController?.showSuccessAlert(
            successContent: "Password updated successfully",
            centreImage: nil,
            okButtonAction: { [weak self] in
                self?.replaceRootWithLogin()
            }
        )
    }

    private func replaceRootWithLogin() {
        let navC = LoginHostingController.loginNavigationRoot()
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            window.rootViewController = navC
            window.makeKeyAndVisible()
        }
    }

    private func performForgetPassword(emailId: String, newPassword: String, confirmPassword: String) {
        APIService.forgetPasswordAPICalling(
            hostViewController,
            emailId: emailId,
            password: newPassword,
            confirmPassword: confirmPassword
        ) { [weak self] response in
            Task { @MainActor in
                guard let self else { return }
                self.finishSubmitUI()
                self.handleForgetPasswordResponse(response)
            }
        }
    }
}
