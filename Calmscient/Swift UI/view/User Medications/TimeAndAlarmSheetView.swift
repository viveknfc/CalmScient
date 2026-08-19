//
//  TimeAndAlarmSheetView.swift
//  Calmscient
//
//  SwiftUI medication time/alarm bottom sheet (parity with `BottomSheetTimeAndAlarmVC`).
//
//  Storyboard parity (scene s0d-6b-0kx):
//   • header bar — 70pt tall, 27pt below the safe-area top, `AppBackGroundColor`.
//                  35×35 `closeIcon` 8pt from the leading edge, 35×35 `saveRightMark`
//                  8pt from the trailing edge, centred Lexend-Medium 20 title in
//                  `MainTextColor`.
//   • "Time"     — Lexend-Regular 15 in `MainTextColor`, 16pt insets, 8pt below the bar.
//   • picker     — `.time` / `.wheels`, 150pt tall, 16pt insets, 8pt below the label,
//                  5pt corner radius. Background is `AppViewContentColor` (set in the
//                  legacy `viewDidLoad`, overriding the storyboard's `MainViewBackground`).
//

import SwiftUI

@available(iOS 16.0, *)
struct TimeAndAlarmSheetView: View {

    @ObservedObject var viewModel: TimeAndAlarmSheetViewModel

    var body: some View {
        VStack(spacing: 0) {

            headerBar
                .padding(.top, 27)

            Text(viewModel.timeLabelText)
                .font(.custom(Fonts().lexendRegular, size: 15))
                .foregroundColor(Color("MainTextColor"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 20)
                .padding(.horizontal, 16)
                .padding(.top, 8)

            timePicker
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .background(Color("AppViewContentColor"))
                .cornerRadius(5)
                .padding(.horizontal, 16)
                .padding(.top, 8)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color("AppBackGroundColor"))
        .onChange(of: viewModel.selectedTime) { newValue in
            viewModel.onTimeChanged(newValue)
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        ZStack {
            Color("AppBackGroundColor")

            Text(viewModel.headingLabelString)
                .font(.custom(Fonts().lexendMedium, size: 20))
                .foregroundColor(Color("MainTextColor"))
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(height: 24)

            HStack {
                Button(action: { viewModel.close() }) {
                    Image("closeIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                }
                .buttonStyle(.plain)

                Spacer(minLength: 0)

                Button(action: { viewModel.save() }) {
                    Image("saveRightMark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 70)
    }

    // MARK: - Picker

    /// `UIDatePicker` applies `minimumDate` / `maximumDate` independently, so each
    /// combination is expressed separately.
    @ViewBuilder
    private var timePicker: some View {
        switch (viewModel.minimumDate, viewModel.maximumDate) {
        case let (min?, max?):
            if min <= max {
                DatePicker("", selection: $viewModel.selectedTime, in: min...max, displayedComponents: .hourAndMinute)
            } else {
                DatePicker("", selection: $viewModel.selectedTime, displayedComponents: .hourAndMinute)
            }
        case let (min?, nil):
            DatePicker("", selection: $viewModel.selectedTime, in: min..., displayedComponents: .hourAndMinute)
        case let (nil, max?):
            DatePicker("", selection: $viewModel.selectedTime, in: ...max, displayedComponents: .hourAndMinute)
        case (nil, nil):
            DatePicker("", selection: $viewModel.selectedTime, displayedComponents: .hourAndMinute)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Time & alarm sheet") {
    TimeAndAlarmSheetView(viewModel: TimeAndAlarmSheetViewModel())
}
#endif
