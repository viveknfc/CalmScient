//
//  BottomSheetDatePickerPresenter.swift
//  Calmscient
//
//  Shared presentation for the bottom-sheet date/time picker
//  (same UI as medications month picker and legacy date/time pickers).
//
//  Now backed by SwiftUI `NewPickerView` via `NewPickerHostingController`.
//  Previously instantiated the storyboard `newPickerViewVC` scene from
//  `Taking Control Index.storyboard`; the public API here is unchanged, so all
//  nine call sites are untouched.
//

import SwiftUI
import UIKit

struct BottomSheetDatePickerConfiguration {
    var pickerMode: PickerMode = .date
    var title: String?
    var okButtonTitle: String?
    var cancelButtonTitle: String?
    var minimumDate: Date?
    var maximumDate: Date?
    var initialDate: Date?
    var showsDimmingOverlay: Bool = true
}

final class BottomSheetDatePickerPresenter: NSObject {

    private weak var presentingViewController: UIViewController?
    private var dimmingView: UIView?
    private var onDateSelected: ((Date, Bool) -> Void)?
    private var onDismiss: (() -> Void)?

    func present(
        from presentingViewController: UIViewController,
        configuration: BottomSheetDatePickerConfiguration,
        onDateSelected: @escaping (Date, Bool) -> Void,
        onDismiss: (() -> Void)? = nil
    ) {
        self.presentingViewController = presentingViewController
        self.onDateSelected = onDateSelected
        self.onDismiss = onDismiss

        let picker = NewPickerHostingController(
            configuration: configuration,
            onDateSelected: { [weak self] date, isTimePicker in
                self?.handleDateSelected(date, isTimePicker: isTimePicker)
            },
            onDismissPicker: { [weak self] in
                self?.handleDismissPicker()
            }
        )

        if configuration.showsDimmingOverlay {
            addDimmingOverlay()
        }

        if #available(iOS 15.0, *) {
            if let sheet = picker.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    // Sized from the picker's own content so the `.wheel` date picker
                    // (216pt intrinsic) is never clipped out of view. The previous
                    // hard-coded 270 was ~60pt short and hid the wheels.
                    let sheetHeight = NewPickerView.preferredSheetHeight
                    let customDetent = UISheetPresentationController.Detent.custom { _ in sheetHeight }
                    sheet.detents = [customDetent]
                } else {
                    sheet.detents = [.medium()]
                }
                sheet.largestUndimmedDetentIdentifier = .medium
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            }
        }

        picker.isModalInPresentation = true
        presentingViewController.present(picker, animated: true)
    }

    private func addDimmingOverlay() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: \.isKeyWindow) else { return }

        let dim = UIView(frame: window.bounds)
        dim.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dim.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.addSubview(dim)
        dimmingView = dim
    }

    private func removeDimmingOverlay() {
        dimmingView?.removeFromSuperview()
        dimmingView = nil
    }
}

// MARK: - Picker callbacks
//
// Bodies preserved verbatim from the previous `NewPickerViewDelegate` conformance,
// so the (intentional) double `onDismiss` on OK — once here, once from
// `handleDismissPicker` — behaves exactly as before.

private extension BottomSheetDatePickerPresenter {

    func handleDateSelected(_ date: Date, isTimePicker: Bool) {
        onDateSelected?(date, isTimePicker)
        removeDimmingOverlay()
        onDismiss?()
    }

    func handleDismissPicker() {
        removeDimmingOverlay()
        onDismiss?()
    }
}
