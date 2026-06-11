//
//  TakingControlCalendarStripView.swift
//  Calmscient
//
//  Lavender week calendar strip with colored event dots (Taking Control drinking tab).
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TakingControlCalendarStripView: View {

    @ObservedObject var viewModel: DrinkingControlViewModel

    private let lavender = Color(red: 0.92, green: 0.92, blue: 0.98)
    private let brandPurple = LoginDesignSystem.ColorName.primaryGradientTop

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "calendar")
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 16))
                    .foregroundStyle(brandPurple)

                Button {
                    viewModel.presentFullDatePickerFromBottom?()
                } label: {
                    HStack(spacing: 6) {
                        Text(viewModel.monthYearNavigationTitle(for: viewModel.selectedCalendarDate))
                            .font(LoginDesignSystem.Typography.lexendMedium(size: 16))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(brandPurple)
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 10)

            HStack(spacing: 8) {
                ForEach(viewModel.weekDays(), id: \.self) { day in
                    TakingControlCalendarStripDayCell(
                        day: day,
                        isSelected: viewModel.isStripDaySelected(day),
                        eventColor: viewModel.eventColor(for: day),
                        onSelect: { viewModel.selectCalendarDate(day) }
                    )
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
        .frame(maxWidth: .infinity)
        .background(lavender)
    }
}

@available(iOS 16.0, *)
private struct TakingControlCalendarStripDayCell: View {
    let day: Date
    let isSelected: Bool
    let eventColor: Color?
    let onSelect: () -> Void

    private let brandPurple = LoginDesignSystem.ColorName.primaryGradientTop

    private var weekday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: Utility.shared.getLocaleIdentifier())
        return formatter.string(from: day)
    }

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: day)
    }

    var body: some View {
        Button(action: onSelect) {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(brandPurple)
                        .frame(width: 46, height: 46)
                }

                VStack(spacing: 5) {
                    Text(weekday)
                        .font(LoginDesignSystem.Typography.lexendLight(size: 12))
                    Text(dayNumber)
                        .font(LoginDesignSystem.Typography.lexendRegular(size: 14))

                    Circle()
                        .fill(eventColor ?? .clear)
                        .frame(width: 8, height: 8)
                        .opacity(eventColor == nil ? 0 : 1)
                }
                .padding(.top, 10)
            }
            .foregroundStyle(isSelected ? Color.white : brandPurple)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Calendar strip") {
    let viewModel = DrinkingControlViewModel()
    viewModel.applyPreviewState(
        statCards: TakingControlIndexPreviewData.drinkingStats(),
        calendarEvents: TakingControlIndexPresentation.previewCalendarEvents()
    )
    return TakingControlCalendarStripView(viewModel: viewModel)
}
#endif
