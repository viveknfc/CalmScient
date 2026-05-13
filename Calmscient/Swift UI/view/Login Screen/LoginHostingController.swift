//
//  LoginHostingController.swift
//  Calmscient
//
//  UIKit host for SwiftUI login — app entry replaces storyboard `LoginVC`.
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class LoginHostingController: UIViewController {

    private let viewModel = LoginViewModel()
    private var hostingController: UIHostingController<LoginView>!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        viewModel.hostViewController = self

        hostingController = UIHostingController(rootView: LoginView(viewModel: viewModel))
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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @objc private func handleWillResignActive() {
        viewModel.saveDraftCredentialsForBackground()
    }

    @objc private func handleDidBecomeActive() {
        viewModel.restoreDraftFromUserDefaults()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

@available(iOS 16.0, *)
extension LoginHostingController {

    /// Same presentation as the old storyboard login: root inside a navigation controller with a hidden bar.
    static func loginNavigationRoot() -> UINavigationController {
        let login = LoginHostingController()
        let nav = UINavigationController(rootViewController: login)
        nav.navigationBar.isHidden = true
        return nav
    }
}
