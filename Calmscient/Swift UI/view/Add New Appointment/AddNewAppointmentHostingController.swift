//
//  AddNewAppointmentHostingController.swift
//  Calmscient
//
//  UIKit shell for `AddNewAppointmentView` (navigation + shared date/time pickers).
//
//  Vivek
//  15 May 2026
//

import SwiftUI
import UIKit

final class AddNewAppointmentHostingController: UIViewController {

    private let viewModel: AddNewAppointmentViewModel
    private let datePickerPresenter = BottomSheetDatePickerPresenter()
    private let timePickerPresenter = BottomSheetDatePickerPresenter()
    private var hostingController: UIHostingController<AddNewAppointmentView>!
    private var navigationBackHost: UIHostingController<MedicationNavigationBackButton>?

    init(isEditMode: Bool, editPayload: MedicalAppointmentDetailsByDate?) {
        self.viewModel = AddNewAppointmentViewModel(isEditMode: isEditMode, editPayload: editPayload)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = AddNewAppointmentViewModel(isEditMode: false, editPayload: nil)
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        viewModel.hostViewController = self
        viewModel.presentDatePicker = { [weak self] in self?.presentDatePicker() }
        viewModel.presentTimePicker = { [weak self] in self?.presentTimePicker() }

        hostingController = UIHostingController(rootView: AddNewAppointmentView(viewModel: viewModel))
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
        navigationBackHost = backHost
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = backItem

        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditingFromBackgroundTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        viewModel.onHostWillAppear()
        applyNavigationChrome()
    }

    @objc private func endEditingFromBackgroundTap() {
        view.endEditing(true)
        viewModel.dismissAutocomplete()
    }

    private func presentDatePicker() {
        let configuration = BottomSheetDatePickerConfiguration(
            pickerMode: .date,
            minimumDate: Date(),
            initialDate: viewModel.dateMMddYYYY.isEmpty ? Date() : dateForPicker(from: viewModel.dateMMddYYYY)
        )
        datePickerPresenter.present(from: self, configuration: configuration) { [weak self] date, isTimePicker in
            guard !isTimePicker else { return }
            self?.viewModel.applyDateFromPicker(date)
        }
    }

    private func presentTimePicker() {
        let configuration = BottomSheetDatePickerConfiguration(
            pickerMode: .time,
            initialDate: timeForPicker(from: viewModel.timeHhmma) ?? Date()
        )
        timePickerPresenter.present(from: self, configuration: configuration) { [weak self] date, isTimePicker in
            guard isTimePicker else { return }
            self?.viewModel.applyTimeFromPicker(date)
        }
    }

    private func dateForPicker(from display: String) -> Date {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US")
        df.timeZone = TimeZone.current
        df.dateFormat = "MM/dd/yyyy"
        return df.date(from: display) ?? Date()
    }

    private func timeForPicker(from display: String) -> Date? {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US")
        df.timeZone = TimeZone.current
        df.dateFormat = "hh:mm a"
        return df.date(from: display)
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
