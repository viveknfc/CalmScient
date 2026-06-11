//
//  NextAppointmentsHostingController.swift
//  Calmscient
//
//  UIKit shell for `NextAppointmentsView` (navigation, bottom-sheet date jump).
//
//  Vivek
//  15 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class NextAppointmentsHostingController: UIViewController {

    private let viewModel = NextAppointmentsViewModel()
    private let monthDatePickerPresenter = BottomSheetDatePickerPresenter()
    private var hostingController: UIHostingController<NextAppointmentsView>!

    private var navigationItemOwner: UIViewController {
        if let parent = parent as? NextAppointmentsViewController {
            return parent
        }
        return self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        viewModel.hostViewController = self
        viewModel.presentFullDatePickerFromBottom = { [weak self] in
            self?.presentMonthDatePickerFromBottom()
        }

        hostingController = UIHostingController(rootView: NextAppointmentsView(viewModel: viewModel))
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
        tabBarController?.tabBar.isHidden = false
        tabBarController?.tabBar.selectedItem?.title = viewModel.tabBarHomeTitle
    }

    private func applyNavigationChrome() {
        let owner = navigationItemOwner
        owner.navigationItem.largeTitleDisplayMode = .never
        owner.navigationItem.title = viewModel.navigationChromeTitle

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
        owner.navigationItem.compactScrollEdgeAppearance = appearance

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
            self?.viewModel.openBackToMedicalRecords()
        }, for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        owner.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }

    private func presentMonthDatePickerFromBottom() {
        let configuration = BottomSheetDatePickerConfiguration(
            pickerMode: .date,
            initialDate: viewModel.selectedAnchorDate
        )
        monthDatePickerPresenter.present(from: self, configuration: configuration) { [weak self] date, isTimePicker in
            guard !isTimePicker else { return }
            self?.viewModel.selectAnchorDateFromMonthPicker(date)
        }
    }
}
