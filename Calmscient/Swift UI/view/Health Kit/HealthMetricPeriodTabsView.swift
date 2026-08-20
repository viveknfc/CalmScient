//
//  HealthMetricPeriodTabsView.swift
//  Calmscient
//
//  Week / Month / Year selector on the health metric detail screen. Switching a
//  tab re-requests `wearable-data/average` with the matching `period`.
//
//  Created by NFC Solutions on 19/08/26.
//

import SwiftUI

@available(iOS 16.0, *)
struct HealthMetricPeriodTabsView: View {

    let periods: [HealthMetricAveragePeriod]
    let selectedPeriod: HealthMetricAveragePeriod
    let onSelect: (HealthMetricAveragePeriod) -> Void
    
    private let outerCornerRadius: CGFloat = 8
    private let innerCornerRadius: CGFloat = 6
    
    private enum Style {
        static let accent = Color(hex: "#6D6BB3")
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(periods) { period in
                Button {
                    onSelect(period)
                } label: {
                    Text(period.titleKey.localized)
                        .font(LoginDesignSystem.Typography.lexendRegular(size: 12))
                        .foregroundStyle(period == selectedPeriod ? Color.white : Color.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectionBackground(for: period))
                        .contentShape(RoundedRectangle(cornerRadius: innerCornerRadius, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(period == selectedPeriod ? [.isButton, .isSelected] : [.isButton])
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: outerCornerRadius, style: .continuous)
                .fill(Style.accent)
                .opacity(0.5)
        )
        .padding(.horizontal, 12)
    }

    @ViewBuilder
    private func selectionBackground(for period: HealthMetricAveragePeriod) -> some View {
        if period == selectedPeriod {
            RoundedRectangle(cornerRadius: innerCornerRadius, style: .continuous).fill(LoginDesignSystem.ColorName.primaryGradientTop)
        } else {
            RoundedRectangle(cornerRadius: innerCornerRadius, style: .continuous).fill(Color.clear)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Period tabs") {
    HealthMetricPeriodTabsView(
        periods: HealthMetricAveragePeriod.allCases,
        selectedPeriod: .week,
        onSelect: { _ in }
    )
}
#endif
