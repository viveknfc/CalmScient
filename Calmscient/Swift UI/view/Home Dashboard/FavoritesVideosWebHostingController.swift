//
//  FavoritesVideosWebHostingController.swift
//  Calmscient
//
//  UIKit shell for `FavoritesVideosWebView` — replaces the storyboard
//  `FavoritesVideosWebViewController` scene.
//
//  Subclasses `ViewController` (not `UIViewController`) exactly as the legacy
//  screen did, so it keeps that base class's network monitoring / no-internet
//  banner, custom back button and navigation title font.
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class FavoritesVideosWebHostingController: ViewController {

    private let viewModel: FavoritesVideosWebViewModel
    private var hostingController: UIHostingController<FavoritesVideosWebView>!

    init(urlString: String, navigationTitle: String?) {
        viewModel = FavoritesVideosWebViewModel(urlString: urlString)
        super.init(nibName: nil, bundle: nil)
        if let navigationTitle {
            title = navigationTitle
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackGroundColor")
        navigationController?.isNavigationBarHidden = false

        viewModel.hostViewController = self

        hostingController = UIHostingController(rootView: FavoritesVideosWebView(viewModel: viewModel))
        hostingController.view.backgroundColor = .clear
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        // Storyboard pinned the web view to the safe area on all four edges.
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        hostingController.didMove(toParent: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.onHostDidDisappear()
    }
}

// MARK: - Navigation

@available(iOS 16.0, *)
enum FavoritesVideosWebNavigation {

    /// Replaces `UIStoryboard(name: "FavoritesVideosWebViewController")` +
    /// `instantiateViewController(withIdentifier:)` + `favURL` / `title` assignment.
    static func push(
        urlString: String,
        title: String?,
        from host: UIViewController,
        animated: Bool = true
    ) {
        guard let nav = host.navigationController else { return }
        let webHost = FavoritesVideosWebHostingController(urlString: urlString, navigationTitle: title)
        nav.pushViewController(webHost, animated: animated)
    }
}
