//
//  DayFeedbackHostingController.swift
//  Calmscient
//
//  UIKit host for SwiftUI day feedback (navigation, `NavigationBack`, tab bar when pushed from dashboard).
//
//  Vivek
//  14 May 2026
//
import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class DayFeedbackHostingController: UIViewController {

    private let viewModel: UserIntroDayFeedbackViewModel
    private var hostingController: UIHostingController<DayFeedbackView>!

    /// Retained for parity with storyboard `UserIntroDayFeedbackViewController` (property was unused there).
    var afternoonVC: Bool = false

    init(
        hideSkipButton: Bool = false,
        dashboardNavigationTitle: String? = nil,
        startupDayData: UserStartupScreenDayData? = nil
    ) {
        self.viewModel = UserIntroDayFeedbackViewModel(
            startupDayData: startupDayData,
            dashboardNavigationTitle: dashboardNavigationTitle,
            hideSkipButton: hideSkipButton
        )
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1)

        viewModel.hostViewController = self

        hostingController = UIHostingController(rootView: DayFeedbackView(viewModel: viewModel))
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel.dashboardNavigationTitle != nil {
            navigationController?.setNavigationBarHidden(false, animated: animated)
            viewModel.configureNavigationChrome()
            applyNavigationChrome()
        } else {
            navigationController?.setNavigationBarHidden(true, animated: animated)
            viewModel.configureNavigationChrome()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DayFeedbackEveningReminderScheduler.cancelEveningReminder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        DayFeedbackEveningReminderScheduler.refreshSchedulingIfNeeded()
    }

    private func applyNavigationChrome() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backButtonTitle = ""

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1)
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
        }

        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "NavigationBack")?.withRenderingMode(.alwaysOriginal), for: .normal)
        backButton.addAction(UIAction { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }, for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
