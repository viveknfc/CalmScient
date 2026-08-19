//
//  TimeAndAlarmSheetHostingController.swift
//  Calmscient
//
//  UIKit shell for `TimeAndAlarmSheetView` — replaces the storyboard
//  `BottomSheetTimeAndAlarmVC` scene.
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class TimeAndAlarmSheetHostingController: UIViewController {

    let viewModel = TimeAndAlarmSheetViewModel()
    private var hostingController: UIHostingController<TimeAndAlarmSheetView>!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackGroundColor")

        viewModel.hostViewController = self

        hostingController = UIHostingController(rootView: TimeAndAlarmSheetView(viewModel: viewModel))
        hostingController.view.backgroundColor = .clear
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        hostingController.didMove(toParent: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.onHostWillDisappear()
    }
}

// MARK: - Presentation

@available(iOS 16.0, *)
enum TimeAndAlarmSheetPresentation {

    /// Replaces `UIStoryboard(name: "BottomSheetTimeAndAlarmVC")` +
    /// `instantiateViewController(withIdentifier:)`. Sheet configuration (detents,
    /// delegate) stays with the caller, exactly as before.
    @MainActor static func make(
        medicationAlarm: MedicationAlarm,
        headingLabelString: String,
        onSheetClosed: (() -> Void)?
    ) -> TimeAndAlarmSheetHostingController {
        let sheetHost = TimeAndAlarmSheetHostingController()
        sheetHost.loadViewIfNeeded()
        sheetHost.viewModel.configure(
            medicationAlarm: medicationAlarm,
            headingLabelString: headingLabelString
        )
        sheetHost.viewModel.onSheetClosed = onSheetClosed
        return sheetHost
    }
}
