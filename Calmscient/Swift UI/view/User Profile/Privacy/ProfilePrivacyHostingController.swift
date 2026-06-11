//
//  ProfilePrivacyHostingController.swift
//  Calmscient
//
//  Vivek
//  14 May 2026
//
//  UIKit host for the profile privacy sheet (replaces storyboard `ProfilePrivacyViewController`).
//

import SwiftUI
import UIKit

final class ProfilePrivacyHostingController: UIViewController {

    private let viewModel = ProfilePrivacyViewModel()
    private var hostingController: UIHostingController<ProfilePrivacyView>!

    /// Optional callback when the sheet is dismissed (parity with legacy `onScheetClosed`).
    var onSheetClosed: (() -> Void)?

    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        viewModel.hostViewController = self

        hostingController = UIHostingController(rootView: ProfilePrivacyView(viewModel: viewModel))
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: Notification.Name("RemoveDimmingView"), object: nil)
        onSheetClosed?()
    }
}
