//
//  CheckMailViewModel.swift
//  Calmscient
//
//  Parity with CheckMailVC: validateOTP, resend via generateOTP, then push UpdatePasswordHostingController.
//
//  Vivek
//  14 May 2026
//
import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class CheckMailViewModel: ObservableObject {

    let email: String

    weak var hostViewController: UIViewController?

    @Published var digits: [String] = ["", "", "", ""]
    @Published private(set) var isBusy: Bool = false

    init(email: String) {
        self.email = email
    }

    var instructionPlainText: String {
        let format = AppHelper.getLocalizeString(str: "check_mail_otp_instruction_email_format")
        return String(format: format, email)
    }

    func verifyCode() {
        hostViewController?.view.endEditing(true)

        let otp = digits.joined()
        guard otp.count == 4 else {
            anchorView?.showToast(message: AppHelper.getLocalizeString(str: "check_mail_please_fill_otp"))
            return
        }

        guard NetworkMonitor.shared.isConnected else {
            NoInternetBanner.shared.show()
            return
        }

        isBusy = true
        anchorView?.showToastActivity()

        let params: [String: Any] = ["emailId": email, "otp": otp]
        APIService.validateOTPAPICalling(
            hostViewController,
            params: params,
            method: "POST",
            accessToken: "",
            acces: true,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                guard let self else { return }
                self.finishBusyUI()

                if let message = response as? String {
                    if message.hasPrefix("Error: No Internet Connection") {
                        return
                    }
                    print("CheckMail validateOTP: \(message)")
                    return
                }

                guard let tuple = ValidateOTPResponseParser.result(from: response) else {
                    print("CheckMail validateOTP: unexpected payload")
                    return
                }

                if tuple.code == 400 {
                    self.hostViewController?.showGeneralAlert(
                        image: UIImage(named: "InfoIcon"),
                        imageSize: CGSize(width: 40, height: 40),
                        title: tuple.message,
                        okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                        okAction: {},
                        showDismissButton: false
                    )
                } else {
                    self.pushUpdatePassword()
                }
            }
        }
    }

    func resendOTP() {
        guard NetworkMonitor.shared.isConnected else {
            NoInternetBanner.shared.show()
            return
        }

        isBusy = true
        anchorView?.showToastActivity()

        let params: [String: Any] = ["emailId": email]
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
                self.finishBusyUI()

                if let message = response as? String {
                    if message.hasPrefix("Error: No Internet Connection") {
                        return
                    }
                    print("CheckMail generateOTP: \(message)")
                    return
                }

                if response is [String: Any] {
                    self.anchorView?.endEditing(true)
                } else {
                    print("Unsupported generateOTP response type: \(type(of: response))")
                }
            }
        }
    }

    func setDigit(at index: Int, raw: String) -> Int? {
        let normalized = String(raw.filter(\.isNumber).prefix(1))
        guard index >= 0, index < digits.count else { return nil }
        var copy = digits
        copy[index] = normalized
        digits = copy
        if normalized.count == 1 {
            return min(index + 1, digits.count - 1)
        }
        return nil
    }

    private var anchorView: UIView? {
        hostViewController?.view
    }

    private func pushUpdatePassword() {
        let vc = UpdatePasswordHostingController(email: email)
        hostViewController?.navigationController?.pushViewController(vc, animated: true)
    }

    private func finishBusyUI() {
        isBusy = false
        anchorView?.hideToastActivity()
    }
}
