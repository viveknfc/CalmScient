//
//  WebViewLessonHostingController.swift
//  Calmscient
//
//  UIKit shell for `WebViewLessonView` (navigation, course chrome, script bridge lifecycle).
//
//  Vivek
//  19 May 2026
//

import SwiftUI
import UIKit

final class WebViewLessonHostingController: UIViewController {

    private let viewModel: WebViewLessonViewModel
    private var hostingController: UIHostingController<WebViewLessonView>!

    init(presentation: WebViewLessonPresentation) {
        viewModel = WebViewLessonViewModel(presentation: presentation)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        viewModel.hostViewController = self
        viewModel.onNavigationChromeChanged = { [weak self] in
            self?.applyNavigationChrome()
        }

        hostingController = UIHostingController(rootView: WebViewLessonView(viewModel: viewModel))
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.isHidden = false
        viewModel.onHostWillAppear()
        viewModel.loadInitialRequestIfNeeded()
        applyNavigationChrome()
        configureBarButtons()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.onHostWillDisappear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        viewModel.onHostDidDisappear()
    }

    private func configureBarButtons() {
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "coursesLeftButton")?.withRenderingMode(.alwaysOriginal), for: .normal)
        backButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.openBack()
        }, for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.hidesBackButton = true

        let glossaryButton = UIButton(type: .custom)
        glossaryButton.setImage(UIImage(named: "coursesRightButton")?.withRenderingMode(.alwaysOriginal), for: .normal)
        glossaryButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.openGlossary()
        }, for: .touchUpInside)
        glossaryButton.translatesAutoresizingMaskIntoConstraints = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: glossaryButton)
    }

    private func applyNavigationChrome() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = viewModel.navigationTitle

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
            navBar.tintColor = UIColor(named: "whiteAndBlack")
        }

        navigationController?.setNavigationBarHidden(viewModel.isNavigationBarHidden, animated: false)
    }
}
