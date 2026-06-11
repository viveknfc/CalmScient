//
//  PatientProfileEditHostingController.swift
//  Calmscient
//
//  Date: May 14, 2026
//  UIKit host for `PatientProfileEditView` (pushed from settings profile row).
//
//  Vivek
//  14 May 2026
//
import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class PatientProfileEditHostingController: UIViewController {

    private let viewModel = PatientProfileEditViewModel()
    private var hostingController: UIHostingController<PatientProfileEditView>!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        viewModel.hostViewController = self

        hostingController = UIHostingController(rootView: PatientProfileEditView(viewModel: viewModel))
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

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
