//
//  NeedToTalkViewModel.swift
//  Calmscient
//
//  State, API, and navigation for the emergency resources screen
//  (parity with legacy `NeedToTalkViewController`).
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class NeedToTalkViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    /// Set by the SwiftUI Home stack; nil on the UIKit path, which pushes instead.
    var onOpenRoute: ((HomeRoute) -> Void)?

    @Published private(set) var provider = NeedToTalkProviderPresentation()
    @Published private(set) var rows: [NeedToTalkRowPresentation] = []

    private var hasLoaded = false

    /// Falls back to the key window so this screen still shows toasts when it is
    /// presented without a `hostViewController` (SwiftUI-navigated Home tab).
    private var anchorView: UIView? { Toast.resolvedAnchor(hostViewController?.view) }

    // MARK: - Lifecycle

    /// Parity with `viewDidLoad`: shows the activity toast then fetches once.
    func onHostDidLoad() {
        guard !hasLoaded else { return }
        hasLoaded = true

        anchorView?.showToastActivity()

        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }

        getNeedToTalkData(
            patientId: userInfo.patientID,
            bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken
        ) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            print("Need to talk data is ", json)
                            Task { @MainActor in
                                self?.apply(json: json)
                            }
                        }
                    } else {
                        print("Unable to convert data to JSON")
                    }
                } catch {
                    print("Error converting data to JSON: \(error)")
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }

    private func apply(json: [String: Any]) {
        anchorView?.hideToastActivity()

        if let need = json["providerDetails"] as? [String: Any] {
            var updated = NeedToTalkProviderPresentation()

            if let docName = need["providerName"] as? String {
                updated.name = docName
            } else {
                print("providerName key is missing or not a String")
            }
            if let docNameSub = need["location"] as? String {
                updated.location = docNameSub
            } else {
                print("providerName key is missing or not a String")
            }
            if let docNamePhone = need["phoneNumber"] as? String {
                updated.phoneNumber = docNamePhone
            } else {
                updated.phoneNumber = ""
            }

            provider = updated
        } else {
            print("providerDetails key is missing or not a dictionary")
        }

        if let needArray = json["needToTalkWithSomeOne"] as? [[String: Any]] {
            rows = needArray.enumerated().map { index, event in
                NeedToTalkRowPresentation(
                    id: index,
                    title: (event["title"] as? String) ?? NeedToTalkPresentation.noTitleKey.localized,
                    content: event["content"] as? String,
                    learnMoreURL: event["learnMore"] as? String
                )
            }
        } else {
            print("Failed to cast JSON data")
        }
    }

    // MARK: - Actions

    /// Parity with `callPhoneNumber()`.
    func callProvider() {
        guard let url = provider.callURL,
              UIApplication.shared.canOpenURL(url) else {
            // Optionally handle invalid number or error
            return
        }
        UIApplication.shared.open(url)
    }

    /// Parity with `learnMoreButtonClicked(_:)`.
    func openLearnMore(for row: NeedToTalkRowPresentation) {
        guard let url = row.learnMoreURL else { return }
        if let onOpenRoute {
            onOpenRoute(.favoritesWeb(
                urlString: url,
                title: NeedToTalkPresentation.navigationTitleKey.localized
            ))
            return
        }
        guard let host = hostViewController else { return }
        FavoritesVideosWebNavigation.push(
            urlString: url,
            title: NeedToTalkPresentation.navigationTitleKey.localized,
            from: host
        )
    }

    // MARK: - API (moved verbatim from `NeedToTalkViewController`)

    func getNeedToTalkData(
        patientId: Int,
        bearerToken: String,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        guard NetworkMonitor.shared.isConnected else {
            DispatchQueue.main.async {
                NoInternetBanner.shared.show()
            }
            return
        }

        guard let url = URL(string: "\(baseURLString)identity/api/v1/settings/getNeedToTalkWithSomeoneDetails") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")

        let payload: [String: Any] = [
            "patientId": patientId,
        ]
        print("payload\(payload)")

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = jsonData
            print(jsonData)
        } catch {
            print("Error converting payload to JSON: \(error)")
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error with request: \(error)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("No data received")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            completion(.success(data))
        }

        task.resume()
    }
}

// MARK: - Navigation

@available(iOS 16.0, *)
enum NeedToTalkNavigation {

    /// Replaces `UIStoryboard(name: "NeedToTalkViewController")` +
    /// `instantiateViewController(withIdentifier:)`.
    ///
    /// Callers used to assign `vc.title` before pushing, but the legacy `viewDidLoad`
    /// immediately overwrote it with `"Emergency resources".localized` — so the title
    /// is fixed here and callers no longer pass one.
    static func push(from host: UIViewController, animated: Bool = true) {
        guard let nav = host.navigationController else { return }
        nav.pushViewController(NeedToTalkHostingController(), animated: animated)
    }
}
