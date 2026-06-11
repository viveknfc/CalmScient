//
//  MedicationsDetailHostingController.swift
//  Calmscient
//
//  UIKit shell for `MedicationsDetailView` (pushed from medications list).
//

//  Vivek
//  15 May 2026
//
import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class MedicationsDetailHostingController: UIViewController {

    private let viewModel: MedicationsDetailViewModel
    private var hostingController: UIHostingController<MedicationsDetailView>!
    private var medicationNavigationBackHost: UIHostingController<MedicationNavigationBackButton>?

    init(medicineDetails: MedicineDetails) {
        self.viewModel = MedicationsDetailViewModel(medicineDetails: medicineDetails)
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

        hostingController = UIHostingController(rootView: MedicationsDetailView(viewModel: viewModel))
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
        title = AppHelper.getLocalizeString(str: "Medications detail")
        viewModel.onHostWillAppear()
        applyNavigationChrome()
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
