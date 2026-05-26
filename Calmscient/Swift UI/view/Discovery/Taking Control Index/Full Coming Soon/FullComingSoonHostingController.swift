//
//  FullComingSoonHostingController.swift
//  Calmscient
//
//  UIKit host for the full-version coming soon modal (replaces storyboard `FullComingSoonVC`).
//
//  Vivek
//  20 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class FullComingSoonHostingController: UIViewController {

    private let viewModel = FullComingSoonViewModel()
    private var hostingController: UIHostingController<FullComingSoonView>!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        viewModel.hostViewController = self

        hostingController = UIHostingController(rootView: FullComingSoonView(viewModel: viewModel))
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
}
