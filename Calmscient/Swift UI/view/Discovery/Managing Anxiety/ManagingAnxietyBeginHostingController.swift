//
//  ManagingAnxietyBeginHostingController.swift
//
//  Calmscient
//
//  Purple status bar overlay + UIKit nav bar (localized title, NavigationBack).
//
//  Vivek
//  19 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class ManagingAnxietyBeginHostingController: UIViewController {

    private let viewModel = ManagingAnxietyBeginViewModel()
    private var hostingController: UIHostingController<ManagingAnxietyBeginView>!
    private var navigationBackHost: UIHostingController<MedicationNavigationBackButton>?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = StatusBarBackgroundOverlay.discoveryNavBarPurple

        viewModel.hostViewController = self

        hostingController = UIHostingController(rootView: ManagingAnxietyBeginView(viewModel: viewModel))
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

        let (backItem, backHost) = MedicationFlowNavigationBarBackItem.leadingBarButton { [weak self] in
            self?.viewModel.openBack()
        }
        navigationBackHost = backHost
        navigationItem.leftBarButtonItem = backItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.view.backgroundColor = StatusBarBackgroundOverlay.discoveryNavBarPurple
        ManagingAnxietyBeginStatusBarAppearance.usesLightContent = true
        StatusBarBackgroundOverlay.show(color: StatusBarBackgroundOverlay.discoveryNavBarPurple)
        viewModel.onHostWillAppear()
        applyNavigationChrome()
        refreshStatusBarAppearance()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        StatusBarBackgroundOverlay.show(color: StatusBarBackgroundOverlay.discoveryNavBarPurple)
        refreshStatusBarAppearance()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ManagingAnxietyBeginStatusBarAppearance.usesLightContent = false
        StatusBarBackgroundOverlay.hide()
        refreshStatusBarAppearance()
        resetNavigationChrome()
    }

    private func applyNavigationChrome() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = viewModel.screenTitle

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = StatusBarBackgroundOverlay.discoveryNavBarPurple
        appearance.shadowColor = UIColor.white.withAlphaComponent(0.25)
        if let titleFont = UIFont(name: Fonts().lexendMedium, size: 18) {
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: titleFont,
            ]
        }

        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.compactScrollEdgeAppearance = appearance

        guard let navBar = navigationController?.navigationBar else { return }
        navBar.isTranslucent = false
        navBar.barStyle = .black
        navBar.tintColor = .white
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance = appearance
        navBar.compactScrollEdgeAppearance = appearance
    }

    private func resetNavigationChrome() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.shadowColor = nil

        navigationItem.standardAppearance = nil
        navigationItem.scrollEdgeAppearance = nil
        navigationItem.compactAppearance = nil
        navigationItem.compactScrollEdgeAppearance = nil

        guard let navBar = navigationController?.navigationBar else { return }
        navBar.isTranslucent = true
        navBar.barStyle = .default
        navBar.tintColor = nil
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance = appearance
        navBar.compactScrollEdgeAppearance = appearance
    }

    private func refreshStatusBarAppearance() {
        setNeedsStatusBarAppearanceUpdate()
        var responder: UIResponder? = view
        while let next = responder?.next {
            if let viewController = next as? UIViewController {
                viewController.setNeedsStatusBarAppearanceUpdate()
            }
            responder = next
        }
    }
}
