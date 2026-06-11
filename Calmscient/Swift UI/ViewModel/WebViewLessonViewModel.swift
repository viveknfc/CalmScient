//
//  WebViewLessonViewModel.swift
//  Calmscient
//
//  State, web bridge, and navigation for course web lessons (parity with `WebViewLessonViewController`).
//
//  Vivek
//  19 May 2026
//

import Foundation
import SwiftUI
import UIKit
import WebKit

@MainActor
final class WebViewLessonViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var navigationTitle: String = ""
    @Published private(set) var isNavigationBarHidden = false

    private let presentation: WebViewLessonPresentation
    private var hasAlreadyPopped = false
    private var hasLoadedInitialRequest = false
    private var loadingToastDismissWorkItem: DispatchWorkItem?

    weak var webView: WKWebView?

    var lessonURLString: String { presentation.urlString }

    var onNavigationChromeChanged: (() -> Void)?

    init(presentation: WebViewLessonPresentation) {
        self.presentation = presentation
        navigationTitle = presentation.initialNavigationTitle ?? ""
    }

    var requestURL: URL? {
        URL(string: presentation.urlString)
    }

    var courseIndex: Int { presentation.courseIndex }

    // MARK: - Host lifecycle

    func onHostWillAppear() {
        navigationController?.toolbar.isHidden = true
        navigationController?.navigationBar.setTitleVerticalPositionAdjustment(0, for: .default)
        showLoadingToast()
        scheduleLoadingToastDismissal()
    }

    func onHostWillDisappear() {
        navigationController?.navigationBar.setTitleVerticalPositionAdjustment(-5, for: .default)
        hostViewController?.navigationItem.leftBarButtonItem = nil
        hostViewController?.navigationItem.rightBarButtonItem = nil
        hostViewController?.navigationItem.hidesBackButton = false
    }

    func onHostDidDisappear() {
        NotificationCenter.default.post(name: .favLanUpdated, object: nil)
    }

    // MARK: - Navigation actions

    func openGlossary() {
        guard let host = hostViewController else { return }
        GlossaryNavigation.push(from: host)
    }

    func openBack() {
        UserDefaults.standard.set(false, forKey: "hasFetchedFavorites")
        evaluateJavaScript(WebViewLessonScripts.stopMediaAndAbort) { [weak self] in
            self?.tearDownWebView()
            self?.popIfNeededAfterManualBack()
        }
    }

    // MARK: - WebView

    func registerWebView(_ webView: WKWebView) {
        self.webView = webView
    }

    func loadInitialRequestIfNeeded() {
        guard !hasLoadedInitialRequest else { return }
        guard let webView else {
            print("[WebViewLesson] load skipped: webView is nil")
            return
        }
        guard let url = requestURL else {
            print("[WebViewLesson] load skipped: invalid URL from \(presentation.urlString)")
            return
        }
        hasLoadedInitialRequest = true
        print("[WebViewLesson] loading \(url.absoluteString)")
        webView.load(URLRequest(url: url))
    }

    func makeWebViewConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.addUserScript(WebViewLessonScripts.disableZoomUserScript)
        return configuration
    }

    func injectAccessTokenIfNeeded() {
        guard let webView,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }
        webView.evaluateJavaScript(WebViewLessonScripts.accessTokenInjection(token: token), completionHandler: nil)
    }

    // MARK: - Script bridge (`nativeDispatch`)

    func handleNativeDispatchMessage(_ messageBody: [String: Any]) {
        for (key, value) in messageBody {
            handleNativeDispatchKey(key, value: value)
        }
    }

    private func handleNativeDispatchKey(_ key: String, value: Any) {
        switch key {
        case "1001":
            handleCourseComplete()
        case "1002":
            if let title = value as? String, !title.isEmpty {
                setNavigationTitle(title)
            }
            setNavigationBarHidden(false)
        case "1100":
            hideLoadingToast()
            if !presentation.pageTitle.isEmpty {
                setNavigationTitle(presentation.pageTitle)
            }
            setNavigationBarHidden(false)
        case "1003":
            setNavigationBarHidden(true)
        case "401":
            setNavigationBarHidden(false)
            presentGenericErrorAlert()
        case "1005":
            break
        case "1008":
            pushTakingControlIndex()
        case "1009":
            pushChangingStressCourse()
        default:
            setNavigationBarHidden(false)
        }
    }

    private func handleCourseComplete() {
        guard !hasAlreadyPopped, presentation.shouldPopOnCourseComplete else { return }
        hasAlreadyPopped = true
        if presentation.courseIndex == 3 {
            setNavigationTitle("Your results")
        }
        setNavigationBarHidden(false)
        navigationController?.popViewController(animated: true)
    }

    private func pushTakingControlIndex() {
        guard let host = hostViewController else { return }
        TakingControlIndexNavigation.push(from: host, shouldPopBack: true)
    }

    private func pushChangingStressCourse() {
        guard let host = hostViewController else { return }
        CoursesNavigation.push(
            courseID: 3,
            title: "Changing your response to stress".localized,
            from: host
        )
    }

    // MARK: - Private helpers

    private var navigationController: UINavigationController? {
        hostViewController?.navigationController
    }

    private var anchorView: UIView? {
        hostViewController?.view
    }

    private func setNavigationTitle(_ title: String) {
        navigationTitle = title
        hostViewController?.navigationItem.title = title
        onNavigationChromeChanged?()
    }

    private func setNavigationBarHidden(_ hidden: Bool) {
        isNavigationBarHidden = hidden
        navigationController?.setNavigationBarHidden(hidden, animated: false)
        navigationController?.isNavigationBarHidden = hidden
    }

    private func showLoadingToast() {
        anchorView?.showToastActivity()
    }

    private func hideLoadingToast() {
        loadingToastDismissWorkItem?.cancel()
        loadingToastDismissWorkItem = nil
        anchorView?.hideToastActivity()
    }

    private func scheduleLoadingToastDismissal() {
        loadingToastDismissWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.hideLoadingToast()
        }
        loadingToastDismissWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: work)
    }

    private func evaluateJavaScript(_ script: String, completion: @escaping () -> Void) {
        webView?.evaluateJavaScript(script) { _, error in
            if let error {
                print("WebViewLesson JavaScript error: \(error)")
            }
            completion()
        }
    }

    private func tearDownWebView() {
        webView?.navigationDelegate = nil
        webView?.uiDelegate = nil
        webView?.stopLoading()
        webView?.removeFromSuperview()
        webView = nil
    }

    private func popIfNeededAfterManualBack() {
        guard presentation.shouldPopOnCourseComplete else { return }
        if presentation.courseIndex == 3 {
            setNavigationTitle("Your results")
        }
        navigationController?.popViewController(animated: true)
    }

    private func presentGenericErrorAlert() {
        guard let host = hostViewController else { return }
        let alert = UIAlertController(
            title: "Error Occured",
            message: "Error occured. Please try again!!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
        host.present(alert, animated: true)
    }

    #if DEBUG
    func applyPreviewState(title: String = "Preview lesson") {
        setNavigationTitle(title)
    }
    #endif
}

// MARK: - JavaScript

private enum WebViewLessonScripts {
    static let disableZoomUserScript = WKUserScript(
        source: """
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            document.getElementsByTagName('head')[0].appendChild(meta);
            """,
        injectionTime: .atDocumentEnd,
        forMainFrameOnly: true
    )

    static let stopMediaAndAbort = """
        document.querySelectorAll('audio, video').forEach(el => {
            el.pause();
            el.currentTime = 0;
            el.src = '';
            el.load();
        });
        if (typeof onAbortCourseGotoIndex === 'function') {
            onAbortCourseGotoIndex();
        }
        """

    static func accessTokenInjection(token: String) -> String {
        """
        (function waitForFn(){
            if (window && typeof window.onAccessTokenReceived === 'function') {
                window.onAccessTokenReceived('\(token)');
            } else {
                setTimeout(waitForFn, 200);
            }
        })();
        """
    }
}

// MARK: - Navigation

enum WebViewLessonNavigation {

    static func push(
        presentation: WebViewLessonPresentation,
        from host: UIViewController,
        animated: Bool = true
    ) {
        guard let nav = host.navigationController else { return }

        let lessonHost = WebViewLessonHostingController(presentation: presentation)
        nav.pushViewController(lessonHost, animated: animated)
    }
}
