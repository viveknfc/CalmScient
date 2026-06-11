//
//  WeeklySummaryGraphHostingController.swift
//  Calmscient
//
//  UIKit container for `WeeklySummaryGraphView` (navigation, `NavigationBack`, network refresh).
//
//  Vivek
//  18 May 2026
//

import Network
import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class WeeklySummaryGraphHostingController: UIViewController {

    let viewModel = WeeklySummaryGraphViewModel()
    private var hostingController: UIHostingController<WeeklySummaryGraphView>!

    private let networkMonitor = NWPathMonitor()
    private let networkQueue = DispatchQueue(label: "com.calmscient.weeklySummaryGraph.network")
    private var isConnected = true

    func configure(summaryType: WeeklySummaryItems) {
        viewModel.configure(summaryType: summaryType)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        viewModel.hostViewController = self

        hostingController = UIHostingController(rootView: WeeklySummaryGraphView(viewModel: viewModel))
        hostingController.view.backgroundColor = .clear
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        hostingController.didMove(toParent: self)

        startNetworkMonitoring()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.isHidden = false
        viewModel.onHostWillAppear()
        applyNavigationChrome()
        tabBarController?.tabBar.isHidden = false
        tabBarController?.tabBar.selectedItem?.title = "main_tab_bar_home".localized
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopNetworkMonitoring()
    }

    private func applyNavigationChrome() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = viewModel.navigationChromeTitle

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        if let customFont = UIFont(name: Fonts().lexendMedium, size: 18) {
            appearance.titleTextAttributes = [
                .font: customFont,
                .foregroundColor: UIColor.black,
            ]
        }
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()

        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.compactScrollEdgeAppearance = appearance

        if let navBar = navigationController?.navigationBar {
            navBar.isTranslucent = false
            navBar.standardAppearance = appearance
            navBar.scrollEdgeAppearance = appearance
            navBar.compactAppearance = appearance
            navBar.compactScrollEdgeAppearance = appearance
            navBar.shadowImage = UIImage()
        }

        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "NavigationBack")?.withRenderingMode(.alwaysOriginal), for: .normal)
        backButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.openBack()
        }, for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }

    private func startNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    if !self.isConnected {
                        self.isConnected = true
                        NoInternetBanner.shared.hide()
                        self.viewModel.onNetworkRestored()
                    }
                } else {
                    self.isConnected = false
                    NoInternetBanner.shared.show()
                    self.viewModel.onNetworkLost()
                }
            }
        }
        networkMonitor.start(queue: networkQueue)
    }

    private func stopNetworkMonitoring() {
        networkMonitor.cancel()
    }
}
