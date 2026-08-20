//
//  HealthMetricInsightsCardView.swift
//  Calmscient
//
//  "Insights" card under the averages chart. Values are derived on device from
//  the buckets the averages endpoint returns (the API sends no insight text).
//
//  Created by NFC Solutions on 19/08/26.
//

import SwiftUI

@available(iOS 16.0, *)
struct HealthMetricInsightsCardView: View {

    let insights: [HealthMetricInsight]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Insights".localized)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                .foregroundStyle(Color.primary)
                .padding(.horizontal, 16)

            VStack(spacing: 0) {
                ForEach(Array(insights.enumerated()), id: \.element.id) { index, insight in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text(insight.title)
                            .font(LoginDesignSystem.Typography.lexendRegular(size: 12))
                            .foregroundStyle(.secondary)

                        Spacer(minLength: 8)

                        Text(insight.valueText)
                            .font(LoginDesignSystem.Typography.lexendMedium(size: 12))
                            .foregroundStyle(Color.primary)
                            .multilineTextAlignment(.trailing)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    if index < insights.count - 1 {
                        Divider()
                            .padding(.leading, 16)
                    }
                }
            }
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
            .padding(.horizontal, 16)
        }
    }

    private var cardBackground: Color {
        if let uiColor = UIColor(named: "AppViewContentColor") {
            return Color(uiColor)
        }
        return Color(red: 0.984, green: 0.984, blue: 0.996)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Insights card") {
    HealthMetricInsightsCardView(insights: [
        HealthMetricInsight(title: "Average", valueText: "78.2 bpm"),
        HealthMetricInsight(title: "Highest", valueText: "79.8 bpm (JUL)"),
        HealthMetricInsight(title: "Lowest", valueText: "76.7 bpm (AUG)"),
        HealthMetricInsight(title: "Change", valueText: "-3.1 bpm vs JUL"),
        HealthMetricInsight(title: "Days with data", valueText: "30"),
    ])
}
#endif
