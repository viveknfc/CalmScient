//
//  WebViewLessonView.swift
//  Calmscient
//
//  SwiftUI web content for course lessons (parity with legacy `WebViewLessonViewController`).
//
//  Vivek
//  19 May 2026
//

import SwiftUI
import WebKit

@available(iOS 16.0, *)
struct WebViewLessonView: View {

    @ObservedObject var viewModel: WebViewLessonViewModel

    var body: some View {
        WebViewLessonRepresentable(viewModel: viewModel)
            .ignoresSafeArea(edges: .bottom)
    }
}

@available(iOS 16.0, *)
private struct WebViewLessonRepresentable: UIViewRepresentable {

    @ObservedObject var viewModel: WebViewLessonViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = viewModel.makeWebViewConfiguration()
        configuration.userContentController.add(
            context.coordinator,
            name: WebViewLessonScriptBridge.handlerName
        )

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.isHidden = false

        viewModel.registerWebView(webView)
        viewModel.loadInitialRequestIfNeeded()
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        viewModel.registerWebView(webView)
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        uiView.configuration.userContentController.removeScriptMessageHandler(
            forName: WebViewLessonScriptBridge.handlerName
        )
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {

        private let viewModel: WebViewLessonViewModel

        init(viewModel: WebViewLessonViewModel) {
            self.viewModel = viewModel
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == WebViewLessonScriptBridge.handlerName,
                  let body = message.body as? [String: Any] else {
                return
            }
            print("--------\(body)-----------")
            viewModel.handleNativeDispatchMessage(body)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.isHidden = false
            viewModel.injectAccessTokenIfNeeded()
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            preferences: WKWebpagePreferences
        ) async -> WKNavigationActionPolicy {
            preferences.allowsContentJavaScript = true
            print("User Redirected to \(String(describing: navigationAction.request.url))")
            return .allow
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print(error)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print(error)
        }
    }
}

@available(iOS 16.0, *)
private enum WebViewLessonScriptBridge {
    static let handlerName = "nativeDispatch"
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Web lesson") {
    WebViewLessonView(
        viewModel: WebViewLessonViewModel(
            presentation: WebViewLessonPresentationPreviewData.sampleManagingAnxiety
        )
    )
}
#endif
