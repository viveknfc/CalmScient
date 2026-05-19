//
//  CitationWebView.swift
//  Calmscient
//
//  SwiftUI web content for sources and citations (parity with legacy `CitationWebViewController`).
//
//  Vivek
//  19 May 2026
//

import SwiftUI
import WebKit

@available(iOS 16.0, *)
struct CitationWebView: View {

    @ObservedObject var viewModel: CitationWebViewModel

    var body: some View {
        CitationWebViewRepresentable(viewModel: viewModel)
            .ignoresSafeArea(edges: .bottom)
    }
}

@available(iOS 16.0, *)
private struct CitationWebViewRepresentable: UIViewRepresentable {

    @ObservedObject var viewModel: CitationWebViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator
        viewModel.registerWebView(webView)
        viewModel.loadInitialRequestIfNeeded()
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        viewModel.registerWebView(webView)
    }

    final class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        private let viewModel: CitationWebViewModel

        init(viewModel: CitationWebViewModel) {
            self.viewModel = viewModel
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            viewModel.endLoading()
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            viewModel.endLoading()
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            viewModel.endLoading()
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Citation web") {
    CitationWebView(viewModel: CitationWebViewModel())
}
#endif
