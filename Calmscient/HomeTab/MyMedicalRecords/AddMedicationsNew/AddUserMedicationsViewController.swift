//
//  AddUserMedicationsViewController.swift
//  Calmscient
//
//  UIKit shell hosting SwiftUI add / edit medication (`AddEditMedicationView`).
//

import SwiftUI
import UIKit

final class AddUserMedicationsViewController: UIViewController, UISheetPresentationControllerDelegate {

    /// Legacy dimming overlay used while the time & alarm bottom sheet is visible.
    var dimmingView: UIView?

    private let expiryDatePickerPresenter = BottomSheetDatePickerPresenter()
    private let viewModel: AddEditMedicationViewModel
    private var hostingController: UIHostingController<AddEditMedicationView>!
    private var medicationNavigationBackHost: UIHostingController<MedicationNavigationBackButton>?

    /// Programmatic entry (preferred).
    init(viewModel: AddEditMedicationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    /// Storyboard / nib entry — defaults to add mode without refresh callback.
    required init?(coder: NSCoder) {
        self.viewModel = AddEditMedicationViewModel(isEditMode: false, medicationData: nil, refreshControlClosure: nil)
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        viewModel.hostViewController = self
        viewModel.medicationFlowHost = self
        viewModel.presentExpiryDatePicker = { [weak self] in
            self?.presentExpiryDatePicker()
        }

        hostingController = UIHostingController(rootView: AddEditMedicationView(viewModel: viewModel))
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
            self?.navigationController?.popViewController(animated: true)
        }
        medicationNavigationBackHost = backHost
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = backItem

        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditingFromBackgroundTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func endEditingFromBackgroundTap() {
        view.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        viewModel.onHostWillAppear()
        applyNavigationChrome()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let presentingVC = presentingViewController as? AddUserMedicationsViewController {
            presentingVC.clearMedicationFlowDimming()
        }
    }

    func clearMedicationFlowDimming() {
        dimmingView?.removeFromSuperview()
        dimmingView = nil
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        clearMedicationFlowDimming()
    }

    private func presentExpiryDatePicker() {
        let configuration = BottomSheetDatePickerConfiguration(
            pickerMode: .date,
            title: "Expiry date".localized,
            okButtonTitle: AppHelper.getLocalizeString(str: "Save"),
            cancelButtonTitle: AppHelper.getLocalizeString(str: "Cancel"),
            minimumDate: Calendar.current.startOfDay(for: Date()),
            initialDate: viewModel.expiryDateForPickerPresentation()
        )
        expiryDatePickerPresenter.present(from: self, configuration: configuration) { [weak self] date, isTimePicker in
            guard !isTimePicker, let self else { return }
            self.viewModel.applyExpiryDateFromPicker(date)
        }
    }

    private func applyNavigationChrome() {
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
}
