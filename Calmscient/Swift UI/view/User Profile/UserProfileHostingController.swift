//
//  UserProfileHostingController.swift
//  Calmscient
//
//  UIKit host for SwiftUI settings / user profile.
//
//  Vivek
//  14 May 2026
//
import SwiftUI
import UIKit

final class UserProfileHostingController: UIViewController {

    private let viewModel = UserProfileViewModel()
    private var hostingController: UIHostingController<UserProfileView>!
    var dimmingView: UIView?

    /// When true, back pops this screen instead of navigating home.
    var shouldPopBack: Bool {
        get { viewModel.shouldPopBack }
        set { viewModel.shouldPopBack = newValue }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Storyboard scene may still embed legacy views; SwiftUI is the sole UI.
        view.subviews.forEach { $0.removeFromSuperview() }
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(false, animated: false)

        viewModel.hostViewController = self

        hostingController = UIHostingController(rootView: UserProfileView(viewModel: viewModel))
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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(removeDimmingView),
            name: Notification.Name("RemoveDimmingView"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshLocalizedNavigationTitle),
            name: .languageChanged,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        refreshLocalizedNavigationTitle()
        navigationItem.largeTitleDisplayMode = .never

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
        if #available(iOS 15.0, *) {
            navigationItem.compactScrollEdgeAppearance = appearance
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

        let backButtonImage = UIImage(named: "NavigationBack")?.withRenderingMode(.alwaysOriginal)
        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonOverrideAction), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let presentingVC = presentingViewController as? UserProfileHostingController {
            presentingVC.dimmingView?.removeFromSuperview()
            presentingVC.dimmingView = nil
        }
    }

    @objc private func removeDimmingView() {
        dimmingView?.removeFromSuperview()
        dimmingView = nil
    }

    @objc private func refreshLocalizedNavigationTitle() {
        title = "Settings".localized
    }

    @objc private func backButtonOverrideAction() {
        if shouldPopBack {
            navigationController?.popViewController(animated: true)
        } else if UserDefaults.standard.bool(forKey: "shouldPopToDis") {
            if #available(iOS 16.0, *) {
                navigationController?.pushViewController(DiscoveryMainHostingController(), animated: true)
            }
        } else {
            if #available(iOS 16.0, *) {
                let homeRoot = HomeDashboardHostingController()
                navigationController?.pushViewController(homeRoot, animated: true)
            }
        }
    }

    func addDimmingView() {
        if dimmingView != nil { return }
        if let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            let overlay = UIView(frame: window.bounds)
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            window.addSubview(overlay)
            dimmingView = overlay
        }
    }

    func removeDimmingViewIfNeeded() {
        removeDimmingView()
    }
}

// MARK: - Image picker

extension UserProfileHostingController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) { [weak self] in
            self?.view.hideToastActivity()
        }
        guard let image = info[.originalImage] as? UIImage else { return }
        viewModel.handlePickedProfileImage(image)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        view.hideToastActivity()
        picker.dismiss(animated: true)
    }
}

// MARK: - Alarm sheet delegate

extension UserProfileHostingController: SettingsAlarmDelegate {
    func didUpdateAlarmValue(_ newValue: Int) {
        viewModel.didUpdateAlarmFromSettings(newValue)
    }
}
