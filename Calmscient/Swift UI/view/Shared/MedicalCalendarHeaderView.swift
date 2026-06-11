//
//  MedicalCalendarHeaderView.swift
//  Calmscient
//
//  Reusable lavender calendar header: month wheel trigger + horizontal date strip.
//
//  Vivek
//  15 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MedicalCalendarHeaderView<Provider: MedicalCalendarHeaderProviding>: View {

    @ObservedObject var provider: Provider

    private let lavender = Color(red: 0.92, green: 0.92, blue: 0.98)
    private let brandPurple = LoginDesignSystem.ColorName.primaryGradientTop

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Image(systemName: "calendar")
                        .font(LoginDesignSystem.Typography.lexendRegular(size: 16))
                        .foregroundStyle(brandPurple)

                    Button {
                        provider.presentFullDatePickerFromBottom?()
                    } label: {
                        HStack(spacing: 6) {
                            Text(provider.monthYearNavigationTitle(for: provider.selectedCalendarDate))
                                .font(LoginDesignSystem.Typography.lexendMedium(size: 16))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundStyle(brandPurple)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 10)

            Text(provider.monthYearNavigationTitle(for: provider.selectedCalendarDate))
                .font(LoginDesignSystem.Typography.lexendMedium(size: 14))
                .foregroundStyle(brandPurple)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(provider.calendarStripDays(), id: \.self) { day in
                            MedicalCalendarStripDayCell(
                                day: day,
                                isSelected: provider.isStripDaySelected(day),
                                onSelect: { provider.selectCalendarDate(day) }
                            )
                            .id(provider.stripDayIdentifier(for: day))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
                }
                .onAppear {
                    let id = provider.stripDayIdentifier(for: provider.selectedCalendarDate)
                    DispatchQueue.main.async {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
                .onChange(of: provider.selectedCalendarDate) { newDate in
                    let id = provider.stripDayIdentifier(for: newDate)
                    withAnimation(.easeInOut(duration: 0.25)) {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(lavender)
    }
}

@available(iOS 16.0, *)
private struct MedicalCalendarStripDayCell: View {
    let day: Date
    let isSelected: Bool
    let onSelect: () -> Void

    private let brandPurple = LoginDesignSystem.ColorName.primaryGradientTop

    private var weekday: String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        f.locale = Locale(identifier: Utility.shared.getLocaleIdentifier())
        return f.string(from: day)
    }

    private var dayNumber: String {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: day)
    }

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 5) {
                Text(weekday)
                    .font(LoginDesignSystem.Typography.lexendLight(size: 12))
                Text(dayNumber)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
            }
            .foregroundStyle(isSelected ? Color.white : brandPurple)
            .frame(width: 46, height: 56)
            .background(
                Group {
                    if isSelected {
                        Circle()
                            .fill(brandPurple)
                    } else {
                        Color.clear
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Medical calendar header — medications") {
    MedicalCalendarHeaderView(provider: UserMedicationsViewModel())
}

@available(iOS 16.0, *)
#Preview("Medical calendar header — appointments") {
    MedicalCalendarHeaderView(provider: NextAppointmentsViewModel())
}
#endif
