//
//  NewPickerView.swift
//  Calmscient
//
//  SwiftUI bottom-sheet date/time picker — 1:1 conversion of the storyboard
//  `newPickerViewVC` scene in `Taking Control Index.storyboard`.
//
//  Storyboard parity notes (scene hRj-PF-ubD):
//   • title    — `FontLM16` label => Lexend-Medium 17, centred, height 20,
//                20pt inset from the safe area on top/leading/trailing.
//                (The old outlet was typed `FontLL15!` but the scene object is
//                `FontLM16`, so Lexend-Medium 17 is what actually rendered.)
//   • buttons  — Lexend-Regular 16, titleColor displayP3(0.4288, 0.4197, 0.6824),
//                height 32, 20pt below the title, 20pt in from each edge.
//   • picker   — `.wheels`, height 150, 20pt below the buttons, pinned to the
//                view edges (not the safe area), background `AppBackGroundColor`,
//                tint = the same purple.
//   • root     — systemBackground.
//
import SwiftUI

/// Date vs time mode for the shared bottom-sheet picker.
///
/// Declared here (rather than in the legacy `newPickerViewVC.swift`) so that the
/// legacy view controller and its storyboard scene can be deleted without taking
/// this enum with them. `BottomSheetDatePickerConfiguration` uses it unchanged.
enum PickerMode {
    case date
    case time
}

@available(iOS 16.0, *)
struct NewPickerView: View {

    // MARK: - Storyboard-derived constants

    /// displayP3 0.42882183 / 0.41974491 / 0.68238306 — the button title colour
    /// and date picker tint from the storyboard scene.
    private static let accent = Color(
        .displayP3,
        red: 0.4288218319,
        green: 0.4197449088,
        blue: 0.6823830605,
        opacity: 1
    )

    private static let horizontalInset: CGFloat = 20
    private static let verticalSpacing: CGFloat = 20
    private static let titleHeight: CGFloat = 20
    private static let buttonRowHeight: CGFloat = 32

    /// A `.wheel` date picker has a fixed intrinsic height of 216pt and refuses to
    /// compress below it. The storyboard used a 150pt box, which SwiftUI honours for
    /// *layout* while the wheels still draw at 216 — so they overflowed the 270pt
    /// sheet and got clipped away. Using the intrinsic height keeps the wheels inside
    /// the sheet and fully visible.
    static let pickerHeight: CGFloat = 216

    /// Height the bottom sheet needs so the whole picker fits without clipping.
    /// `BottomSheetDatePickerPresenter` uses this for its custom detent.
    static var preferredSheetHeight: CGFloat {
        verticalSpacing + titleHeight            // title block
            + verticalSpacing + buttonRowHeight  // Cancel / Done row
            + verticalSpacing + pickerHeight     // wheels
            + verticalSpacing                    // bottom breathing room
    }

    // MARK: - Input

    let pickerMode: PickerMode
    let title: String
    let okButtonTitle: String
    let cancelButtonTitle: String
    let minimumDate: Date?
    let maximumDate: Date?

    let onOk: (Date) -> Void
    let onCancel: () -> Void

    @State private var selectedDate: Date

    init(
        pickerMode: PickerMode,
        title: String,
        okButtonTitle: String,
        cancelButtonTitle: String,
        minimumDate: Date?,
        maximumDate: Date?,
        initialDate: Date?,
        onOk: @escaping (Date) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.pickerMode = pickerMode
        self.title = title
        self.okButtonTitle = okButtonTitle
        self.cancelButtonTitle = cancelButtonTitle
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.onOk = onOk
        self.onCancel = onCancel
        // `UIDatePicker` defaults to "now" when no date is assigned.
        _selectedDate = State(initialValue: initialDate ?? Date())
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Text(title)
                .font(.custom(Fonts().lexendMedium, size: 17))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: Self.titleHeight)
                .padding(.horizontal, Self.horizontalInset)
                .padding(.top, Self.verticalSpacing)

            HStack(spacing: 0) {
                Button(action: cancelTapped) {
                    Text(cancelButtonTitle)
                        .font(.custom(Fonts().lexendRegular, size: 16))
                        .foregroundColor(Self.accent)
                }

                Spacer(minLength: 0)

                Button(action: okTapped) {
                    Text(okButtonTitle)
                        .font(.custom(Fonts().lexendRegular, size: 16))
                        .foregroundColor(Self.accent)
                }
            }
            .frame(height: Self.buttonRowHeight)
            .padding(.horizontal, Self.horizontalInset)
            .padding(.top, Self.verticalSpacing)

            datePicker
                .datePickerStyle(.wheel)
                .labelsHidden()
                .tint(Self.accent)
                .frame(maxWidth: .infinity)
                .frame(height: Self.pickerHeight)
                .background(Color("AppBackGroundColor"))
                .padding(.top, Self.verticalSpacing)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(uiColor: .systemBackground))
        .environment(\.locale, Locale(identifier: Utility.shared.getLocaleIdentifier()))
    }

    // MARK: - Date picker (range variants)

    /// `UIDatePicker` treats `minimumDate` / `maximumDate` independently, so all
    /// four combinations have to be expressed separately in SwiftUI.
    @ViewBuilder
    private var datePicker: some View {
        switch (minimumDate, maximumDate) {
        case let (min?, max?):
            // Guard against an inverted range, which would trap at runtime.
            if min <= max {
                DatePicker("", selection: $selectedDate, in: min...max, displayedComponents: components)
            } else {
                DatePicker("", selection: $selectedDate, displayedComponents: components)
            }
        case let (min?, nil):
            DatePicker("", selection: $selectedDate, in: min..., displayedComponents: components)
        case let (nil, max?):
            DatePicker("", selection: $selectedDate, in: ...max, displayedComponents: components)
        case (nil, nil):
            DatePicker("", selection: $selectedDate, displayedComponents: components)
        }
    }

    private var components: DatePickerComponents {
        switch pickerMode {
        case .date: return .date
        case .time: return .hourAndMinute
        }
    }

    // MARK: - Actions

    private func okTapped() {
        onOk(selectedDate)
    }

    private func cancelTapped() {
        onCancel()
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Date mode") {
    NewPickerView(
        pickerMode: .date,
        title: "Please select date",
        okButtonTitle: "Done",
        cancelButtonTitle: "Cancel",
        minimumDate: nil,
        maximumDate: Date(),
        initialDate: Date(),
        onOk: { _ in },
        onCancel: {}
    )
}

@available(iOS 16.0, *)
#Preview("Time mode") {
    NewPickerView(
        pickerMode: .time,
        title: "Please select time",
        okButtonTitle: "Done",
        cancelButtonTitle: "Cancel",
        minimumDate: nil,
        maximumDate: nil,
        initialDate: Date(),
        onOk: { _ in },
        onCancel: {}
    )
}
#endif
