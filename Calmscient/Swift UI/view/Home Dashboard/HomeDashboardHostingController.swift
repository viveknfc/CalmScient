//
//  HomeDashboardHostingController.swift
//  Calmscient
//
//  UIKit container for `HomeDashboardView` (main tab home root on iOS 16+).
//
//  Vivek
//  14 May 2026
//
import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class HomeDashboardHostingController: UIViewController {

    private let viewModel = HomeDashboardViewModel()
    private var hostingController: UIHostingController<HomeDashboardView>!
    private var favoritesObserver: NSObjectProtocol?
    private var favLanguageObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)

        viewModel.hostViewController = self

        hostingController = UIHostingController(rootView: HomeDashboardView(viewModel: viewModel))
        hostingController.view.backgroundColor = .clear
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        hostingController.didMove(toParent: self)

        favoritesObserver = NotificationCenter.default.addObserver(
            forName: .favoritesUpdated,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.viewModel.syncFavoritesFromManager()
            self?.view.hideToastActivity()
        }

        favLanguageObserver = NotificationCenter.default.addObserver(
            forName: .favLanUpdated,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.viewModel.fetchFavoritesFromNetwork()
        }

        viewModel.initialLoad()
    }

    deinit {
        if let favoritesObserver {
            NotificationCenter.default.removeObserver(favoritesObserver)
        }
        if let favLanguageObserver {
            NotificationCenter.default.removeObserver(favLanguageObserver)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.onHostWillAppear()
        viewModel.syncFavoritesFromManager()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
