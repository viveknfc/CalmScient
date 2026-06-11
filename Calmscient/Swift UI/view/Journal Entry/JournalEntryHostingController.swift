//
//  JournalEntryHostingController.swift
//  Calmscient
//
//  UIKit shell for `JournalEntryView` (navigation, `NavigationBack`, tab bar).
//
//  Vivek
//  18 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class JournalEntryHostingController: UIViewController {

    let viewModel = JournalEntryViewModel()
    private var hostingController: UIHostingController<JournalEntryView>!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        viewModel.hostViewController = self

        hostingController = UIHostingController(rootView: JournalEntryView(viewModel: viewModel))
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

        viewModel.onHostViewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.onHostWillAppear()
        applyNavigationChrome()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.onHostWillDisappear()
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
}
