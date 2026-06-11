//
//  UpdatePasswordHostingController.swift
//  Calmscient
//
//  UIKit shell for SwiftUI update-password (replaces storyboard `UpdatePasswordVC` on iOS 16+).
//
//  Vivek
//  14 May 2026
//
import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class UpdatePasswordHostingController: UIViewController {

    private let viewModel: UpdatePasswordViewModel
    private var hostingController: UIHostingController<UpdatePasswordView>!

    init(email: String) {
        self.viewModel = UpdatePasswordViewModel(email: email)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        viewModel.hostViewController = self

        hostingController = UIHostingController(rootView: UpdatePasswordView(viewModel: viewModel))
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

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        installBackButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func installBackButton() {
        let backButtonImage = UIImage(named: "NavigationBack")?.withRenderingMode(.alwaysOriginal)
        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
}
