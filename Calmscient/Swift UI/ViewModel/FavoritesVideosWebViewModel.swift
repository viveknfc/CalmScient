//
//  FavoritesVideosWebViewModel.swift
//  Calmscient
//
//  State, web loading, and lifecycle for the favourites / learn-more web screen
//  (parity with legacy `FavoritesVideosWebViewController`).
//

import Foundation
import SwiftUI
import UIKit
import WebKit

@MainActor
final class FavoritesVideosWebViewModel: ObservableObject {

    weak var hostViewController: UIViewController?
    weak var webView: WKWebView?

    /// Legacy `favURL`.
    let urlString: String

    private var hasLoadedInitialRequest = false

    init(urlString: String) {
        self.urlString = urlString
    }

    var requestURL: URL? { URL(string: urlString) }

    // MARK: - WebView

    /// Mirrors the storyboard's `wkWebViewConfiguration`, which set
    /// `mediaTypesRequiringUserActionForPlayback = none` so favourite videos can
    /// autoplay without a tap.
    func makeWebViewConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.mediaTypesRequiringUserActionForPlayback = []
        return configuration
    }

    func registerWebView(_ webView: WKWebView) {
        self.webView = webView
    }

    /// Parity with `loadFavoriteURL()`: the activity toast is shown unconditionally,
    /// then the request is only issued when `favURL` parses into a `URL`.
    func loadFavoriteURLIfNeeded() {
        guard !hasLoadedInitialRequest else { return }
        guard let webView else { return }
        hasLoadedInitialRequest = true

        showLoadingToast()

        if let url = requestURL {
            webView.load(URLRequest(url: url))
        }
    }

    // MARK: - Navigation delegate callbacks (all three hid the toast)

    func onNavigationFinished() {
        hideLoadingToast()
    }

    func onNavigationFailed(_ error: Error) {
        print("[FavoritesVideosWeb] navigation failed: \(error.localizedDescription)")
        hideLoadingToast()
    }

    // MARK: - Host lifecycle

    /// Legacy `viewDidDisappear` posted this so the dashboard refreshes favourites.
    func onHostDidDisappear() {
        NotificationCenter.default.post(name: .favLanUpdated, object: nil)
        print("called notification for fav updated from webview direct open")
    }

    // MARK: - Toast

    /// Falls back to the key window so this screen still shows toasts when it is
    /// presented without a `hostViewController` (SwiftUI-navigated Home tab).
    private var anchorView: UIView? { Toast.resolvedAnchor(hostViewController?.view) }

    private func showLoadingToast() { anchorView?.showToastActivity() }

    private func hideLoadingToast() { anchorView?.hideToastActivity() }
}
