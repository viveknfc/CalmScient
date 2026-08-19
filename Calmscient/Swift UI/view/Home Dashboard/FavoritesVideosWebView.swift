//
//  FavoritesVideosWebView.swift
//  Calmscient
//
//  SwiftUI web content for favourite videos and "Learn more" links
//  (parity with legacy `FavoritesVideosWebViewController`).
//
//  Storyboard parity (scene s0d-6b-0kx): a single `WKWebView` pinned to the safe
//  area on all four edges, `AppBackGroundColor` behind both the root view and the
//  web view, and a configuration allowing media playback without user action.
//

import SwiftUI
import WebKit

@available(iOS 16.0, *)
struct FavoritesVideosWebView: View {

    @ObservedObject var viewModel: FavoritesVideosWebViewModel

    var body: some View {
        FavoritesVideosWebRepresentable(viewModel: viewModel)
            .background(Color("AppBackGroundColor"))
    }
}

/// `viewModel` is deliberately a plain reference (not `@ObservedObject`) so the
/// `WKWebView` is never torn down and reloaded by an unrelated publish.
@available(iOS 16.0, *)
private struct FavoritesVideosWebRepresentable: UIViewRepresentable {

    let viewModel: FavoritesVideosWebViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: viewModel.makeWebViewConfiguration())
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator
        webView.backgroundColor = UIColor(named: "AppBackGroundColor")

        viewModel.registerWebView(webView)
        viewModel.loadFavoriteURLIfNeeded()
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        viewModel.registerWebView(webView)
        if webView.navigationDelegate == nil {
            webView.navigationDelegate = context.coordinator
        }
        if webView.uiDelegate == nil {
            webView.uiDelegate = context.coordinator
        }
    }

    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
        webView.stopLoading()
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {

        private let viewModel: FavoritesVideosWebViewModel

        init(viewModel: FavoritesVideosWebViewModel) {
            self.viewModel = viewModel
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            Task { @MainActor in viewModel.onNavigationFinished() }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            Task { @MainActor in viewModel.onNavigationFailed(error) }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            Task { @MainActor in viewModel.onNavigationFailed(error) }
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Favourites web") {
    FavoritesVideosWebView(
        viewModel: FavoritesVideosWebViewModel(urlString: "https://www.apple.com")
    )
}
#endif
