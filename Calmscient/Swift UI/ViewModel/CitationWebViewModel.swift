//
//  CitationWebViewModel.swift
//  Calmscient
//
//  State and navigation for sources and citations web content (parity with `CitationWebViewController`).
//
//  Vivek
//  19 May 2026
//

import SwiftUI
import UIKit
import WebKit

@available(iOS 16.0, *)
@MainActor
final class CitationWebViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    private let presentation: CitationWebPresentation

    @Published private(set) var navigationTitle: String = ""
    @Published private(set) var pageURLString: String = ""

    weak var webView: WKWebView?

    init(presentation: CitationWebPresentation = CitationWebPresentation()) {
        self.presentation = presentation
        pageURLString = presentation.pageURL
        reloadLocalizedStrings()
    }

    func reloadLocalizedStrings() {
        navigationTitle = "sources_and_citations_title".localized
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
    }

    var requestURL: URL? {
        URL(string: pageURLString)
    }

    func openBack() {
        if let webView, webView.canGoBack {
            webView.goBack()
        } else {
            hostViewController?.navigationController?.popViewController(animated: true)
        }
    }

    func beginLoading() {
        hostViewController?.view.showToastActivity()
    }

    func endLoading() {
        hostViewController?.view.hideToastActivity()
        reloadLocalizedStrings()
    }

    func registerWebView(_ webView: WKWebView) {
        self.webView = webView
    }

    func loadInitialRequestIfNeeded() {
        guard let webView, let url = requestURL else { return }
        if webView.url == nil {
            beginLoading()
            webView.load(URLRequest(url: url))
        }
    }
}
