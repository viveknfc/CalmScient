//
//  WeeklySummaryDashboardHostingController.swift
//  Calmscient
//
//  UIKit container for `WeeklySummaryDashboardView` (navigation, `NavigationBack`, tab bar).
//
//  Vivek
//  17 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class WeeklySummaryDashboardHostingController: UIViewController {

    private let viewModel = WeeklySummaryDashboardViewModel()
    private var hostingController: UIHostingController<WeeklySummaryDashboardView>!

    private var navigationItemOwner: UIViewController { self }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        viewModel.hostViewController = self

        hostingController = UIHostingController(rootView: WeeklySummaryDashboardView(viewModel: viewModel))
        hostingController.view.backgroundColor = .clear
        hostingController.view.clipsToBounds = true
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        let topLayoutGuide: UILayoutGuide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        hostingController.didMove(toParent: self)
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

    private func applyNavigationChrome() {
        let owner = navigationItemOwner
        owner.navigationItem.largeTitleDisplayMode = .never
        owner.navigationItem.title = viewModel.screenTitle

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

        owner.navigationItem.standardAppearance = appearance
        owner.navigationItem.scrollEdgeAppearance = appearance
        owner.navigationItem.compactAppearance = appearance
        owner.navigationItem.compactScrollEdgeAppearance = appearance

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
        owner.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
}
