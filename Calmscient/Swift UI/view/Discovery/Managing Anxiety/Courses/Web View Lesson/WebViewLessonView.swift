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

struct WebViewLessonView: View {

    @ObservedObject var viewModel: WebViewLessonViewModel

    var body: some View {
        WebViewLessonRepresentable(viewModel: viewModel)
            .id(viewModel.lessonURLString)
            .ignoresSafeArea(edges: .bottom)
    }
}

/// `viewModel` is intentionally not `@ObservedObject` here so WKWebView is not torn down
/// when navigation title / bar visibility publishes from `nativeDispatch`.
private struct WebViewLessonRepresentable: UIViewRepresentable {

    let viewModel: WebViewLessonViewModel

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
        print("[WebViewLesson] makeUIView — handler registered")
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

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        uiView.navigationDelegate = nil
        uiView.uiDelegate = nil
        uiView.stopLoading()
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
            print("[WebViewLesson] nativeDispatch received name=\(message.name) body=\(message.body)")

            guard message.name == WebViewLessonScriptBridge.handlerName else { return }

            guard let body = message.body as? [String: Any] else {
                print("[WebViewLesson] nativeDispatch body is not [String: Any], type=\(type(of: message.body))")
                return
            }

            print("--------\(body)-----------")
            Task { @MainActor in
                viewModel.handleNativeDispatchMessage(body)
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.isHidden = false
            print("[WebViewLesson] didFinish url=\(webView.url?.absoluteString ?? "nil")")
            viewModel.injectAccessTokenIfNeeded()
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            preferences: WKWebpagePreferences,
            decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void
        ) {
            preferences.allowsContentJavaScript = true
            print("User Redirected to \(navigationAction.request.url?.absoluteString ?? "nil")")
            decisionHandler(.allow, preferences)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("[WebViewLesson] didFail: \(error.localizedDescription)")
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("[WebViewLesson] didFailProvisional: \(error.localizedDescription)")
        }
    }
}

private enum WebViewLessonScriptBridge {
    static let handlerName = "nativeDispatch"
}

#if DEBUG
#Preview("Web lesson") {
    WebViewLessonView(
        viewModel: WebViewLessonViewModel(
            presentation: WebViewLessonPresentationPreviewData.sampleManagingAnxiety
        )
    )
}
#endif
