//
//  QuitSymptomModalHostingController.swift
//  Calmscient
//
//  UIKit host for ready-to-quit symptom modals (replaces storyboard symptom VCs).
//
//  Vivek
//  26 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class QuitSymptomModalHostingController: UIViewController {

    private let viewModel: QuitSymptomModalViewModel
    private var hostingController: UIHostingController<QuitSymptomModalView>!

    init(topic: QuitSymptomTopic) {
        self.viewModel = QuitSymptomModalViewModel(topic: topic)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        viewModel.hostViewController = self

        hostingController = UIHostingController(rootView: QuitSymptomModalView(viewModel: viewModel))
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
