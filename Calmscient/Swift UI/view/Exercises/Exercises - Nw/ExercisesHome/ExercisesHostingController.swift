//
//  ExercisesHostingController.swift
//  Calmscient
//
//  UIKit shell for `ExercisesView` (tab root, citations button).
//
//  Vivek
//  26 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class ExercisesHostingController: UIViewController {

    private let viewModel = ExercisesViewModel()
    private var hostingController: UIHostingController<ExercisesView>!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        viewModel.hostViewController = self

        hostingController = UIHostingController(rootView: ExercisesView(viewModel: viewModel))
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.isHidden = false
        viewModel.onHostWillAppear()
        applyNavigationChrome()
    }

    private func applyNavigationChrome() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = viewModel.screenTitle

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        if let customFont = UIFont(name: Fonts().lexendMedium, size: 18) {
            appearance.titleTextAttributes = [
                .font: customFont,
                .foregroundColor: UIColor.label,
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

        // Tab root: no back button.
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true

        if let image = UIImage(named: "Citation")?.withRenderingMode(.alwaysOriginal) {
            let button = UIButton(type: .custom)
            button.setImage(image, for: .normal)
            button.imageView?.contentMode = .scaleAspectFill
            button.contentHorizontalAlignment = .fill
            button.contentVerticalAlignment = .fill
            button.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
            button.addAction(UIAction { [weak self] _ in
                self?.viewModel.openCitationSources()
            }, for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
}

