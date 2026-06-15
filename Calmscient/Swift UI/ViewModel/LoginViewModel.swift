//
//  LoginViewModel.swift
//  Calmscient
//
//  Login + post-login startup flow (parity with LoginVC).
//
//  Vivek
//  14 May 2026
//
import Combine
import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class LoginViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published var username: String = ""
    @Published var password: String = ""
    @Published var acceptTermsSelected: Bool = true
    @Published var rememberMeSelected: Bool = false
    @Published var isPasswordVisible: Bool = false
    @Published private(set) var isPerformingLogin: Bool = false

    private let termsURL = URL(string: "https://calmscient.in/courses/terms-of-service")!
    func restoreDraftFromUserDefaults() {
        if let u = UserDefaults.standard.string(forKey: "temp_username") {
            username = u
        }
        if let p = UserDefaults.standard.string(forKey: "temp_password") {
            password = p
        }
    }

    func saveDraftCredentialsForBackground() {
        UserDefaults.standard.set(username, forKey: "temp_username")
        UserDefaults.standard.set(password, forKey: "temp_password")
    }

    func clearDraftCredentials() {
        UserDefaults.standard.removeObject(forKey: "temp_username")
        UserDefaults.standard.removeObject(forKey: "temp_password")
    }

    func openTermsOfService() {
        UIApplication.shared.open(termsURL)
    }

    func submitLogin() {
        let userNameText = username.trimmingCharacters(in: .whitespaces)
        guard !userNameText.isEmpty else {
            anchorView?.showToast(message: "Username or Password can't be empty.")
            return
        }
        guard !password.isEmpty else {
            anchorView?.showToast(message: "Password can't be empty.")
            return
        }
        if userNameText.contains(" ") || password.contains(" ") {
            let alert = UIAlertController(
                title: "Error",
                message: "Username and Password should not contain spaces.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
            hostViewController?.present(alert, animated: true)
            return
        }
        guard acceptTermsSelected else {
            anchorView?.showToast(message: "Accept Terms and Conditions")
            return
        }

        guard NetworkMonitor.shared.isConnected else {
            NoInternetBanner.shared.show()
            return
        }

        clearDraftCredentials()
        isPerformingLogin = true
        anchorView?.showToastActivity()
        performLoginRequest(userName: userNameText, password: password)
    }

    func retryLoginAfterStartupFailure() {
        submitLogin()
    }

    func navigateForgotPassword() {
        hostViewController?.navigationController?.setNavigationBarHidden(false, animated: true)
        let forgot = ForgotPasswordHostingController()
        hostViewController?.navigationController?.pushViewController(forgot, animated: true)
    }

    func navigateLicenseValidation() {
        UserDefaults.standard.set(true, forKey: "isFirstLaunch")
        hostViewController?.navigationController?.setNavigationBarHidden(false, animated: true)
        let license = LicenseValidationHostingController()
        license.navigationItem.title = ""
        hostViewController?.navigationController?.pushViewController(license, animated: true)
    }

    // MARK: - Private

    private var anchorView: UIView? {
        hostViewController?.view
    }

    private func performLoginRequest(userName: String, password: String) {
        let timeZoneIdentifier = TimeZone.current.identifier
        let token = UserDefaults.standard.string(forKey: "FCM_TOKEN") ?? ""
        let payload = LoginRequestPayload(
            userName: userName,
            password: password,
            rememberMe: 0,
            deviceToken: token,
            mobilePlatform: "IOS",
            timeZone: timeZoneIdentifier
        )

        let startTime = Date()
        APIService.userLoginAPICalling(
            hostViewController,
            params: payload.asRequestParameters,
            method: "POST",
            accessToken: "",
            acces: true,
            parameterPlacement: "body"
        ) { [weak self] response in
            let elapsed = Date().timeIntervalSince(startTime)
            print("the response TIme taking for login VC is: \(elapsed) seconds")

            Task { @MainActor in
                guard let self else { return }

                if let message = response as? String {
                    self.finishLoginRequestUI()
                    if message.hasPrefix("Error: No Internet Connection") {
                        return
                    }
                    let trimmed = message.replacingOccurrences(of: "Error: ", with: "")
                    self.anchorView?.showToast(
                        message: trimmed.isEmpty ? "An unknown error occured. Please Try Again!" : trimmed
                    )
                    return
                }

                guard let dict = response as? [String: Any],
                      let data = try? JSONSerialization.data(withJSONObject: dict) else {
                    self.finishLoginRequestUI()
                    self.anchorView?.showToast(message: "Please Try Again!")
                    return
                }

                NetworkLogger.log(response: data)

                if let loginResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                    self.handleLoginSuccess(loginResponse)
                } else if let failureResponse = try? JSONDecoder().decode(FailureResponse.self, from: data) {
                    self.finishLoginRequestUI()
                    self.anchorView?.showToast(message: failureResponse.statusResponse.responseMessage)
                } else {
                    self.finishLoginRequestUI()
                    self.anchorView?.showToast(message: "Please Try Again!")
                }
            }
        }
    }

    private func handleLoginSuccess(_ loginResponse: LoginResponse) {
        if loginResponse.statusResponse.responseCode != 200 {
            finishLoginRequestUI()
            anchorView?.showToast(message: loginResponse.statusResponse.responseMessage)
            return
        }

        ApplicationSharedInfo.shared.loginResponse = loginResponse.loginDetails
        ApplicationSharedInfo.shared.tokenResponse = loginResponse.tokenResponse

        if rememberMeSelected {
            UserDefaults.standard.set(1, forKey: "rememberMe")
        } else {
            UserDefaults.standard.set(0, forKey: "rememberMe")
        }

        TokenManager.shared.saveTokenData(
            accessToken: loginResponse.tokenResponse.accessToken,
            expiresIn: loginResponse.tokenResponse.expiresIn
        )

        UserDefaultsHelper.saveLoginDetailsToUserDefaults(
            loginDetails: loginResponse.loginDetails,
            tokenResponse: loginResponse.tokenResponse
        )

        UserDefaults.standard.set("\(loginResponse.loginDetails.firstName)", forKey: "titleString")
        PatientLanguagePreference.persistLoginLanguage(languageId: loginResponse.loginDetails.languageId)

        let loginCount = loginResponse.loginDetails.loginCount
        if loginCount == 1 {
            finishLoginRequestUI()
            let vc = UpdatePasswordHostingController(email: loginResponse.loginDetails.email)
            let nav = UINavigationController(rootViewController: vc)
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.changeRootViewController(to: nav)
            }
        } else {
            callUserStartupAfterLogin()
        }
    }

    private func callUserStartupAfterLogin() {
        guard let loginResponse = ApplicationSharedInfo.shared.loginResponse,
              let tokenResponse = ApplicationSharedInfo.shared.tokenResponse else {
            finishLoginRequestUI()
            return
        }

        let params = DayFeedbackSessionLogic.userStartupAPIParameters(
            patientLocationId: loginResponse.patientLocationID,
            clientId: loginResponse.clientID,
            patientId: loginResponse.patientID
        )

        APIService.userStartUpAPICalling(
            hostViewController,
            params: params,
            method: "POST",
            accessToken: tokenResponse.accessToken,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleUserStartupResponse(response)
            }
        }
    }

    private func handleUserStartupResponse(_ response: AnyObject) {
        finishLoginRequestUI()

        if response is String {
            let alertController = UIAlertController(
                title: "Error".localized,
                message: "Failed to fetch data. Would you like to retry?".localized,
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "Retry".localized, style: .default) { [weak self] _ in
                self?.retryLoginAfterStartupFailure()
            })
            alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))
            hostViewController?.present(alertController, animated: true)
            return
        }

        guard let responseDict = response as? [String: Any] else {
            print("Unsupported response type:", type(of: response))
            return
        }

        guard let responseMessage = responseDict["saved"] as? Int else {
            print("Response Message not found or is not a string.")
            return
        }

        let navController: UINavigationController
        if DayFeedbackSessionLogic.shouldShowDayFeedbackAfterLogin(saved: responseMessage) {
            let homeViewController = DayFeedbackHostingController()
            homeViewController.afternoonVC = true
            navController = UINavigationController(rootViewController: homeViewController)
        } else {
            let storyboard = UIStoryboard(name: "AppTabBar", bundle: nil)
            let homeViewController = storyboard.instantiateViewController(withIdentifier: "AppMainTabViewController") as! AppMainTabViewController
            homeViewController.isInitalView = false
            navController = UINavigationController(rootViewController: homeViewController)
            navController.navigationBar.isHidden = true
        }

        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.changeRootViewController(to: navController)
        }

        DispatchQueue.main.async {
            DayFeedbackEveningReminderScheduler.refreshSchedulingIfNeeded()
        }
    }

    private func finishLoginRequestUI() {
        isPerformingLogin = false
        anchorView?.hideToastActivity()
    }
}
