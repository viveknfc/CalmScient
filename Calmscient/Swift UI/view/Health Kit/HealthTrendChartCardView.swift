//
//  HealthTrendChartCardView.swift
//  Calmscient
//
//  Created by NFC Solutions on 19/08/26.
//

import SwiftUI

/// The "… Trend" card: a DGCharts bar chart with the value printed above each bar, a
/// dashed period-average line, and the y-axis on the trailing edge.
///
/// The chart itself is `HealthTrendChartRepresentable`; this type owns only the card
/// chrome, so the DGCharts configuration sits beside the app's other chart setup in
/// `Swift UI/view/Chart` rather than inside a screen.
@available(iOS 16.0, *)
struct HealthTrendChartCardView: View {

    let title: String
    let unit: String
    let data: HealthTrendChartData

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.custom(Fonts().lexendMedium, size: 17))
                .foregroundStyle(.primary)

            HealthTrendChartRepresentable(data: data)
                .frame(height: HealthTrendChartConfigurator.chartContentHeight)
                .accessibilityElement()
                .accessibilityLabel(title)
                .accessibilityValue(accessibilitySummary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    /// DGCharts renders into a single UIView with no accessible children, so the whole
    /// series is read out here instead.
    private var accessibilitySummary: String {
        guard data.hasAnyData else { return "No data".localized }
        return data.points
            .filter(\.hasData)
            .map { "\($0.label): \($0.displayValue) \(unit)" }
            .joined(separator: ", ")
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Monthly heart rate") {
    let points: [HealthTrendPoint] = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
                                      "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
        .enumerated()
        .map { index, label in
            let value: Double? = index == 6 ? 79.79 : (index == 7 ? 58.4 : nil)
            return HealthTrendPoint(
                label: label,
                value: value,
                displayValue: value.map { String(Int($0.rounded())) } ?? "0",
                daysWithData: value == nil ? 0 : 24)
        }

    return HealthTrendChartCardView(
        title: "Heart Rate Trend",
        unit: "bpm",
        data: HealthTrendChartData(points: points,
                                   axisMaximum: 180,
                                   average: 69.1,
                                   averageText: "69 bpm")
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
#endif
