//
//  NewPickerHostingController.swift
//  Calmscient
//
//  UIKit shell for `NewPickerView` — drop-in replacement for the storyboard
//  `newPickerViewVC` scene, so `BottomSheetDatePickerPresenter` (and its nine
//  call sites) keep working unchanged.
//
//  Behaviour is a line-for-line port of `newPickerViewVC`:
//   • defaults          — title falls back to "Please select date"/"Please select time",
//                         buttons to "Done"/"Cancel" (all `.localized`).
//   • time normalisation— `.time` mode rebuilds the picked hour/minute onto *today*
//                         with seconds zeroed, and reports `isTimePicker == true`.
//   • callback order    — `onDateSelected` then `onDismissPicker`, both before
//                         `dismiss(animated:)`, matching the old
//                         `didSelectDate` → `didDismissPicker` → `dismiss` sequence.
//
import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class NewPickerHostingController: UIHostingController<NewPickerView> {

    private let pickerMode: PickerMode
    private let onDateSelected: (Date, Bool) -> Void
    private let onDismissPicker: () -> Void

    init(
        configuration: BottomSheetDatePickerConfiguration,
        onDateSelected: @escaping (Date, Bool) -> Void,
        onDismissPicker: @escaping () -> Void
    ) {
        self.pickerMode = configuration.pickerMode
        self.onDateSelected = onDateSelected
        self.onDismissPicker = onDismissPicker

        let defaultTitle: String
        switch configuration.pickerMode {
        case .date: defaultTitle = "Please select date".localized
        case .time: defaultTitle = "Please select time".localized
        }

        // Placeholder closures: the real ones need `self`, wired up below.
        super.init(rootView: NewPickerView(
            pickerMode: configuration.pickerMode,
            title: configuration.title ?? defaultTitle,
            okButtonTitle: configuration.okButtonTitle ?? "Done".localized,
            cancelButtonTitle: configuration.cancelButtonTitle ?? "Cancel".localized,
            minimumDate: configuration.minimumDate,
            maximumDate: configuration.maximumDate,
            initialDate: configuration.initialDate,
            onOk: { _ in },
            onCancel: {}
        ))

        rootView = NewPickerView(
            pickerMode: configuration.pickerMode,
            title: configuration.title ?? defaultTitle,
            okButtonTitle: configuration.okButtonTitle ?? "Done".localized,
            cancelButtonTitle: configuration.cancelButtonTitle ?? "Cancel".localized,
            minimumDate: configuration.minimumDate,
            maximumDate: configuration.maximumDate,
            initialDate: configuration.initialDate,
            onOk: { [weak self] date in self?.okTapped(with: date) },
            onCancel: { [weak self] in self?.cancelTapped() }
        )
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }

    // MARK: - Actions (parity with `newPickerViewVC.okButtonTapped` / `.cancelButtonTapped`)

    private func okTapped(with selectedDate: Date) {
        if pickerMode == .time {
            // Extract only the time part, same as the legacy controller.
            let calendar = Calendar.current
            let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedDate)
            let normalizedTime = calendar.date(
                bySettingHour: timeComponents.hour ?? 0,
                minute: timeComponents.minute ?? 0,
                second: 0,
                of: Date()
            ) ?? selectedDate

            onDateSelected(normalizedTime, true)
        } else {
            // Send full date.
            onDateSelected(selectedDate, false)
        }

        onDismissPicker()
        dismiss(animated: true, completion: nil)
    }

    private func cancelTapped() {
        onDismissPicker()
        dismiss(animated: true, completion: nil)
    }
}
