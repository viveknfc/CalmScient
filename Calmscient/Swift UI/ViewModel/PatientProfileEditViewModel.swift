//
//  PatientProfileEditViewModel.swift
//  Calmscient
//
//  Date: May 14, 2026
//  Edit profile + change password (parity with legacy ProfileViewController), using APIService keys.
//
//  Vivek
//  14 May 2026
//
import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class PatientProfileEditViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    // MARK: - SwiftUI navigation
    //
    // Set by `HomeTabView` when this screen is shown inside the Home `NavigationStack`.
    // While nil, every call below falls through to the existing UIKit push/pop, which is
    // what the still-UIKit Discovery tab uses when it pushes into these screens.
    var onOpenRoute: ((HomeRoute) -> Void)?
    var onClose: (() -> Void)?
    var onCloseToRoot: (() -> Void)?

    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var phoneDisplay: String = ""

    @Published var oldPassword: String = ""
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""
    @Published var oldPasswordVisible: Bool = false
    @Published var newPasswordVisible: Bool = false
    @Published var confirmPasswordVisible: Bool = false

    @Published private(set) var isLoadingProfile: Bool = false
    @Published private(set) var isSubmittingProfile: Bool = false
    @Published private(set) var isUpdatingPassword: Bool = false

    private let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?\":{}|<>])[A-Za-z\\d!@#$%^&*(),.?\":{}|<>]{8,}$"

    /// Falls back to the key window so this screen still shows toasts when it is
    /// presented without a `hostViewController` (SwiftUI-navigated Home tab).
    private var anchorView: UIView? { Toast.resolvedAnchor(hostViewController?.view) }

    func onAppear() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            applyPreviewSampleDataIfNeeded()
            return
        }
        loadPatientProfile()
    }

    func dismissScreen() {
        if let onClose {
            onClose()
            return
        }
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    func submitProfile() {
        anchorView?.endEditing(true)

        let first = firstName.trimmingCharacters(in: .whitespaces)
        let last = lastName.trimmingCharacters(in: .whitespaces)

        guard !first.isEmpty else {
            anchorView?.showToast(message: "First Name can't be empty.")
            return
        }
        guard !last.isEmpty else {
            anchorView?.showToast(message: "Last Name can't be empty.")
            return
        }
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            anchorView?.showToast(message: "Email can't be empty.")
            return
        }

        guard let userInfo = ApplicationSharedInfo.shared.loginResponse,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }

        guard NetworkMonitor.shared.isConnected else {
            NoInternetBanner.shared.show()
            return
        }

        isSubmittingProfile = true
        anchorView?.showToastActivity()

        let params: [String: Any] = [
            "patientId": userInfo.patientID,
            "firstName": first,
            "lastName": last,
            "email": email,
            "phone": phoneDisplay,
        ]

        APIService.updatePatientProfileDetailsAPICalling(
            hostViewController,
            params: params,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                guard let self else { return }
                self.isSubmittingProfile = false
                self.anchorView?.hideToastActivity()
                self.handleUpdateProfileResponse(response)
            }
        }
    }

    func updatePasswordTapped() {
        anchorView?.endEditing(true)

        guard let userInfo = ApplicationSharedInfo.shared.loginResponse,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }

        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        guard !trimmedEmail.isEmpty else {
            hostViewController?.showGeneralAlert(
                image: UIImage(named: "InfoIcon"),
                imageSize: CGSize(width: 40, height: 40),
                title: "Email is required.",
                okButtonTitle: "Ok".localized,
                okAction: {},
                showDismissButton: false
            )
            return
        }

        guard !oldPassword.isEmpty else {
            presentInfoAlert(title: AppHelper.getLocalizeString(str: "All fields are required"))
            return
        }
        guard !newPassword.isEmpty else {
            presentInfoAlert(title: AppHelper.getLocalizeString(str: "All fields are required"))
            return
        }
        guard NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: newPassword) else {
            hostViewController?.showGeneralAlert(
                image: UIImage(named: "InfoIcon"),
                imageSize: CGSize(width: 40, height: 40),
                title: "Your password must be at least eight characters long and include at least one special character and one number.",
                okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                okAction: {},
                showDismissButton: false
            )
            return
        }
        guard !confirmPassword.isEmpty else {
            presentInfoAlert(title: AppHelper.getLocalizeString(str: "All fields are required"))
            return
        }
        guard newPassword == confirmPassword else {
            hostViewController?.showGeneralAlert(
                image: UIImage(named: "InfoIcon"),
                imageSize: CGSize(width: 40, height: 40),
                title: "New password and confirm password must be the same.",
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

        isUpdatingPassword = true
        anchorView?.showToastActivity()

        let params: [String: Any] = [
            "emailId": trimmedEmail,
            "userId": userInfo.userID,
            "oldPassword": oldPassword,
            "newPassword": newPassword,
            "confirmNewPassword": confirmPassword,
            "patientId": userInfo.patientID,
            "clientId": userInfo.clientID,
        ]

        APIService.updatePasswordAPICalling(
            hostViewController,
            params: params,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                guard let self else { return }
                self.isUpdatingPassword = false
                self.anchorView?.hideToastActivity()
                self.handleUpdatePasswordResponse(response)
            }
        }
    }

    // MARK: - Private

    private func loadPatientProfile() {
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }

        guard NetworkMonitor.shared.isConnected else {
            NoInternetBanner.shared.show()
            return
        }

        isLoadingProfile = true
        anchorView?.showToastActivity()

        APIService.getPatientProfileDetailsAPICalling(
            hostViewController,
            params: ["patientId": userInfo.patientID],
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                guard let self else { return }
                self.isLoadingProfile = false
                self.anchorView?.hideToastActivity()
                self.applyPatientProfileDetailsResponse(response)
            }
        }
    }

    private func applyPatientProfileDetailsResponse(_ response: AnyObject) {
        guard let dict = response as? [String: Any],
              let details = dict["patientProfileDetails"] as? [String: Any] else {
            return
        }
        if let v = details["firstName"] as? String { firstName = v }
        if let v = details["lastName"] as? String { lastName = v }
        if let v = details["emailAddress"] as? String { email = v }
        if let v = details["phone"] as? String {
            phoneDisplay = Self.formattedUSPhone(number: v)
        }
    }

    private func handleUpdateProfileResponse(_ response: AnyObject) {
        guard let dict = response as? [String: Any] else {
            print("Unsupported update profile response:", type(of: response))
            return
        }
        let message = dict["responseMessage"] as? String
        hostViewController?.showSuccessAlert(successContent: message, centreImage: nil) { [weak self] in
            guard let self else { return }
            if let onClose = self.onClose {
                onClose()
                return
            }
            self.hostViewController?.navigationController?.popViewController(animated: true)
        }
    }

    private func handleUpdatePasswordResponse(_ response: AnyObject) {
        if let responseDict = response as? [String: Any],
           let responseMessage = responseDict["responseMessage"] as? String {
            hostViewController?.showSuccessAlert(successContent: responseMessage, centreImage: nil) { [weak self] in
                self?.oldPassword = ""
                self?.newPassword = ""
                self?.confirmPassword = ""
            }
        } else {
            print("Unsupported response type:", type(of: response))
        }
    }

    private func presentInfoAlert(title: String) {
        hostViewController?.showGeneralAlert(
            image: UIImage(named: "InfoIcon"),
            imageSize: CGSize(width: 40, height: 40),
            title: title,
            okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
            okAction: {},
            showDismissButton: false
        )
    }

    private func applyPreviewSampleDataIfNeeded() {
        guard firstName.isEmpty else { return }
        firstName = "Jane"
        lastName = "Doe"
        email = "1hin4@virgilian.com"
        phoneDisplay = Self.formattedUSPhone(number: "6969696969")
    }

    /// Same mask as legacy `ProfileViewController.formattedNumber(number:)`.
    private static func formattedUSPhone(number: String) -> String {
        let cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "(XXX) XXX XXXX"
        var result = ""
        var index = cleanPhoneNumber.startIndex
        for ch in mask where index < cleanPhoneNumber.endIndex {
            if ch == "X" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
}
