//
//  LaunchScreenViewModel.swift
//  Calmscient
//
//  Version check API and navigation after splash (parity with LaunchScreenVC).
//
//  Vivek
//  27 May 2026
//
import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class LaunchScreenViewModel: ObservableObject {

    weak var hostViewController: UIViewController?
    weak var sceneDelegate: SceneDelegate?

    func onAppear() {
        checkVersionAPI()
    }

    // MARK: - Version check API

    func checkVersionAPI() {
        let params: [String: Any] = [
            "sourceId": "2",
            "version": Bundle.main.appVersion
        ]

        anchorView?.showToastActivity()
        print("the params of version check is \(params)")

        APIService.validateVersionAPICalling(
            hostViewController,
            params: params,
            method: "POST",
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleVersionAPIRawResponse(response)
            }
        }
    }

    private func handleVersionAPIRawResponse(_ response: AnyObject) {
        guard let dict = response as? [String: Any] else {
            print("❌ Response is not a dictionary")
            return
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict)
            let decoder = JSONDecoder()
            let versionResponse = try decoder.decode(VersionResponse.self, from: jsonData)
            getResponseforVersionAPI(versionResponse)
        } catch {
            print("❌ Decoding failed: \(error)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("Missing key: \(key.stringValue) - \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("Type mismatch for type: \(type) - \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("Value not found for type: \(type) - \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("Data corrupted: \(context.debugDescription)")
                @unknown default:
                    print("Unknown decoding error")
                }
            }
        }
    }

    private func getResponseforVersionAPI(_ response: VersionResponse) {
        anchorView?.hideToastActivity()
        print("the version api response is \(response)")

        guard response.mandatoryUpdate == false else {
            showUpdateAlert(forceUpdate: !response.mandatoryUpdate)
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("🕒 Timer done, proceeding to next screen")
            self.sceneDelegate?.proceedAfterSplashScreen()
        }
    }

    private func showUpdateAlert(forceUpdate: Bool) {
        guard let topVC = UIApplication.topViewController() else { return }

        let alert = UIAlertController(
            title: "Update Required",
            message: "A new version of the app is available. Please update to continue.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Update", style: .default) { _ in
            if let url = URL(string: "https://apps.apple.com/in/app/6748917043") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })

        DispatchQueue.main.async {
            topVC.present(alert, animated: true) {
                if let window = UIApplication.shared.connectedScenes
                    .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                    .first {
                    for view in window.subviews {
                        if let dimView = view as? UIVisualEffectView {
                            dimView.alpha = 0.5
                        }
                    }
                }
            }
        }
    }

    private var anchorView: UIView? {
        hostViewController?.view
    }
}
