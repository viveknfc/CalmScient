//
//  NeedToTalkHostingController.swift
//  Calmscient
//
//  UIKit shell for `NeedToTalkView` — replaces the storyboard
//  `NeedToTalkViewController` scene.
//
//  Subclasses `ViewController` exactly as the legacy screen did, so it keeps that
//  base class's network monitoring / no-internet banner and custom back button.
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class NeedToTalkHostingController: ViewController {

    let viewModel = NeedToTalkViewModel()
    private var hostingController: UIHostingController<NeedToTalkView>!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        navigationController?.isNavigationBarHidden = false

        viewModel.hostViewController = self

        hostingController = UIHostingController(rootView: NeedToTalkView(viewModel: viewModel))
        hostingController.view.backgroundColor = .clear
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        hostingController.didMove(toParent: self)

        // Legacy `viewDidLoad` set the title itself, ignoring whatever the caller assigned.
        title = NeedToTalkPresentation.navigationTitleKey.localized
        if let customFont = UIFont(name: Fonts().lexendMedium, size: 18) {
            navigationController?.navigationBar.titleTextAttributes = [.font: customFont]
        }

        viewModel.onHostDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
}
