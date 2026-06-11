//
//  AlarmSettingsHostingController.swift
//  Calmscient
//
//  UIKit host for the alarm settings sheet (replaces storyboard `settingsAlarmVC`).
//
//  Vivek
//  14 May 2026
//
import SwiftUI
import UIKit

protocol SettingsAlarmDelegate: AnyObject {
    func didUpdateAlarmValue(_ newValue: Int)
}

final class AlarmSettingsHostingController: UIViewController {

    private let viewModel: AlarmSettingsViewModel
    private var hostingController: UIHostingController<AlarmSettingsView>!

    init(initialAlarmMinutes: Int, delegate: SettingsAlarmDelegate?) {
        self.viewModel = AlarmSettingsViewModel(initialAlarmMinutes: initialAlarmMinutes)
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = delegate
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

        hostingController = UIHostingController(rootView: AlarmSettingsView(viewModel: viewModel))
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
    }
}
