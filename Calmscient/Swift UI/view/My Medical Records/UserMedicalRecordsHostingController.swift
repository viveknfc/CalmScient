//
//  UserMedicalRecordsHostingController.swift
//  Calmscient
//
//  UIKit container for `UserMedicalRecordsView` (iOS 16+).
//
//  Vivek
//  14 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class UserMedicalRecordsHostingController: UIViewController {

    private let viewModel = UserMedicalRecordsViewModel()
    private var hostingController: UIHostingController<UserMedicalRecordsView>!

    /// When embedded under `UserMedicalRecordsViewController`, the navigation bar shows that parent’s `navigationItem` (top of the stack).
    private var navigationItemOwner: UIViewController {
        if let parent = parent as? UserMedicalRecordsViewController {
            return parent
        }
        return self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        viewModel.hostViewController = self

        hostingController = UIHostingController(rootView: UserMedicalRecordsView(viewModel: viewModel))
        hostingController.view.backgroundColor = .clear
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        let topLayoutGuide: UILayoutGuide = {
            if let parentVC = parent as? UserMedicalRecordsViewController {
                return parentVC.view.safeAreaLayoutGuide
            }
            return view.safeAreaLayoutGuide
        }()

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
        if #available(iOS 15.0, *) {
            owner.navigationItem.compactScrollEdgeAppearance = appearance
        }

        if let navBar = navigationController?.navigationBar {
            navBar.isTranslucent = false
            navBar.standardAppearance = appearance
            navBar.scrollEdgeAppearance = appearance
            navBar.compactAppearance = appearance
            if #available(iOS 15.0, *) {
                navBar.compactScrollEdgeAppearance = appearance
            }
            navBar.shadowImage = UIImage()
        }

        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "NavigationBack")?.withRenderingMode(.alwaysOriginal), for: .normal)
        backButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.openBackToHome()
        }, for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        owner.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)

        let profileButton = UIButton(type: .custom)
        profileButton.setImage(UIImage(named: "profileIcon.png"), for: .normal)
        profileButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.openProfile()
        }, for: .touchUpInside)
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        profileButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        owner.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
    }
}
