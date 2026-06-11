//
//  TakingControlIndexHostingController.swift
//  Calmscient
//
//  UIKit shell for `TakingControlIndexView` (navigation, `NavigationBack`, tab bar).
//
//  Vivek
//  20 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class TakingControlIndexHostingController: UIViewController {

    private let viewModel = TakingControlIndexViewModel()
    private var hostingController: UIHostingController<TakingControlIndexView>!
    private var navigationBackHost: UIHostingController<MedicationNavigationBackButton>?
    private let datePickerPresenter = BottomSheetDatePickerPresenter()

    func configure(initialSegment: Int = 0, shouldPopBack: Bool = false, moveToIntro: Bool = false) {
        viewModel.configure(
            initialSegment: initialSegment,
            shouldPopBack: shouldPopBack,
            moveToIntro: moveToIntro
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        viewModel.hostViewController = self
        viewModel.drinkingViewModel.presentFullDatePickerFromBottom = { [weak self] in
            self?.presentMonthYearPicker()
        }

        hostingController = UIHostingController(rootView: TakingControlIndexView(viewModel: viewModel))
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

        let (backItem, backHost) = MedicationFlowNavigationBarBackItem.leadingBarButton { [weak self] in
            self?.viewModel.openBack()
        }
        navigationBackHost = backHost
        navigationItem.leftBarButtonItem = backItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.isHidden = false
        viewModel.onHostWillAppear()
        applyNavigationChrome()
        tabBarController?.tabBar.isHidden = false
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
    }

    private func presentMonthYearPicker() {
        datePickerPresenter.present(
            from: self,
            configuration: BottomSheetDatePickerConfiguration(
                pickerMode: .date,
                initialDate: viewModel.drinkingViewModel.selectedCalendarDate
            ),
            onDateSelected: { [weak self] date, _ in
                self?.viewModel.drinkingViewModel.selectCalendarDate(date)
            }
        )
    }
}
