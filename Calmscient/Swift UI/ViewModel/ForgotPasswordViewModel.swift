//
//  ForgotPasswordViewModel.swift
//  Calmscient
//
//  Parity with ForgotPasswordVC: POST generateOTP, then push CheckMailVC.
//
//  Vivek
//  14 May 2026
//
import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class ForgotPasswordViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published var emailOrPhone: String = ""
    @Published private(set) var isSubmitting: Bool = false

    func submitResetRequest() {
        let trimmed = emailOrPhone.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            anchorView?.showToast(message: "Please add email address")
            return
        }

        guard NetworkMonitor.shared.isConnected else {
            NoInternetBanner.shared.show()
            return
        }

        isSubmitting = true
        anchorView?.showToastActivity()
        performGenerateOTP(emailId: trimmed)
    }

    // MARK: - Private

    private var anchorView: UIView? {
        hostViewController?.view
    }

    private func performGenerateOTP(emailId: String) {
        let params: [String: Any] = ["emailId": emailId]
        APIService.generateOTPAPICalling(
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

                if let message = response as? String {
                    if message.hasPrefix("Error: No Internet Connection") {
                        return
                    }
                    print("ForgotPassword generateOTP: \(message)")
                    return
                }

                if response is [String: Any] {
                    self.anchorView?.endEditing(true)
                    self.pushCheckMail(email: emailId)
                } else {
                    print("Unsupported generateOTP response type: \(type(of: response))")
                }
            }
        }
    }

    private func pushCheckMail(email: String) {
        let vc = CheckMailHostingController(email: email)
        hostViewController?.navigationController?.pushViewController(vc, animated: true)
    }

    private func finishSubmitUI() {
        isSubmitting = false
        anchorView?.hideToastActivity()
    }
}
