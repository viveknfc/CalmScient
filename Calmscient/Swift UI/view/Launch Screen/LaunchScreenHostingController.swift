//
//  LaunchScreenHostingController.swift
//  Calmscient
//
//  UIKit root host for SwiftUI splash (replaces storyboard LaunchScreenVC).
//
//  Vivek
//  27 May 2026
//
import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class LaunchScreenHostingController: UIViewController {

    weak var sceneDelegate: SceneDelegate?

    private let viewModel = LaunchScreenViewModel()
    private var hostingController: UIHostingController<LaunchScreenView>!
    private var didTriggerVersionCheck = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        viewModel.hostViewController = self
        viewModel.sceneDelegate = sceneDelegate

        hostingController = UIHostingController(rootView: LaunchScreenView())
        hostingController.view.backgroundColor = .clear
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hostingController.didMove(toParent: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didTriggerVersionCheck else { return }
        didTriggerVersionCheck = true
        viewModel.onAppear()
    }
}
