//
//  BottomSheetDatePickerPresenter.swift
//  Calmscient
//
//  Shared presentation for the storyboard `newPickerViewVC` bottom sheet
//  (same UI as medications month picker and legacy date/time pickers).
//

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

        let storyboard = UIStoryboard(name: "Taking Control Index", bundle: nil)
        guard let picker = storyboard.instantiateViewController(withIdentifier: "newPickerViewVC") as? newPickerViewVC else {
            fatalError("Could not instantiate newPickerViewVC")
        }

        picker.delegate = self
        picker.pickerMode = configuration.pickerMode
        picker.pickerTitle = configuration.title
        picker.okButtonTitle = configuration.okButtonTitle
        picker.cancelButtonTitle = configuration.cancelButtonTitle
        picker.minimumDate = configuration.minimumDate
        picker.maximumDate = configuration.maximumDate
        picker.initialDate = configuration.initialDate

        if configuration.showsDimmingOverlay {
            addDimmingOverlay()
        }

        if #available(iOS 15.0, *) {
            if let sheet = picker.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    let customDetent = UISheetPresentationController.Detent.custom { _ in 270 }
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

extension BottomSheetDatePickerPresenter: NewPickerViewDelegate {

    func didSelectDate(_ date: Date, indexPath: IndexPath?, isTimePicker: Bool) {
        onDateSelected?(date, isTimePicker)
        removeDimmingOverlay()
        onDismiss?()
    }

    func didDismissPicker() {
        removeDimmingOverlay()
        onDismiss?()
    }
}
