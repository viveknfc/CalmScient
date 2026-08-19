//
//  AddEditMedicationHostingController.swift
//  Calmscient
//
//  UIKit shell for `AddEditMedicationView` (renamed from `AddUserMedicationsViewController`
//  to match the hosting-controller convention used across the SwiftUI tree).
//
//  The screen itself is entirely SwiftUI — everything below is host-level plumbing that
//  a pushed screen still needs while navigation is `UINavigationController`-based:
//  navigation chrome, the custom back item, and the dimming overlay + sheet delegate for
//  the time & alarm bottom sheet.
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class AddEditMedicationHostingController: UIViewController, UISheetPresentationControllerDelegate {

    /// Legacy dimming overlay used while the time & alarm bottom sheet is visible.
    var dimmingView: UIView?

    private let viewModel: AddEditMedicationViewModel
    private var hostingController: UIHostingController<AddEditMedicationView>!
    private var medicationNavigationBackHost: UIHostingController<MedicationNavigationBackButton>?

    init(viewModel: AddEditMedicationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        viewModel.hostViewController = self
        viewModel.medicationFlowHost = self

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        viewModel.onHostWillAppear()
        applyNavigationChrome()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // NOTE: preserved verbatim from the legacy controller. `presentingViewController`
        // is the controller that *presented* this one, which is never an instance of this
        // class on the push-based medication flow — so this branch does not fire. The
        // dimming overlay is cleared by `presentationControllerDidDismiss` and by
        // `AddEditMedicationViewModel.clearDimmingView()` instead.
        if let presentingVC = presentingViewController as? AddEditMedicationHostingController {
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
