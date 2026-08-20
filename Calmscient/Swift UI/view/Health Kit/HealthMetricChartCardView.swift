//
//  HealthMetricChartCardView.swift
//  Calmscient
//
//  Averages chart for one health metric (SwiftUI Charts). Bars for cumulative
//  metrics (steps, calories, hydration...), line for discrete ones (heart rate,
//  SpO2, weight...). Blood pressure draws two lines.
//
//  Card chrome mirrors `ChartViewTableCellView` so it sits consistently with the
//  Weekly Summary graphs, but shares no code with them (that stack is Int-based
//  DGCharts tuned for mood/score axes).
//
//  Created by NFC Solutions on 19/08/26.
//

import Charts
import SwiftUI

@available(iOS 16.0, *)
struct HealthMetricChartCardView: View {

    let title: String
    let points: [HealthMetricChartPoint]
    /// Every bucket label of the period, in order — keeps empty months on the axis.
    let orderedLabels: [String]
    let useBars: Bool
    let showsLegend: Bool
    let emptyMessage: String

    private let horizontalInset: CGFloat = 16
    /// Same height as the Weekly Summary chart cards, kept as a local constant so
    /// tweaks to those screens can never resize this one.
    private let chartHeight: CGFloat = 279

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                .foregroundStyle(Color.primary)
                .padding(.horizontal, horizontalInset)

            chartCard
                .padding(.horizontal, horizontalInset)
        }
    }

    // MARK: - Card

    private var chartCard: some View {
        Group {
            if points.isEmpty {
                emptyState
            } else {
                chart
            }
        }
        .frame(height: chartHeight)
        .frame(maxWidth: .infinity)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
    }

    private var emptyState: some View {
        Text(emptyMessage)
            .font(LoginDesignSystem.Typography.lexendRegular(size: 12))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Chart

    private var chart: some View {
        Chart(points) { point in
            if useBars {
                BarMark(
                    x: .value("Period".localized, point.label),
                    y: .value("Value".localized, point.value)
                )
                .foregroundStyle(by: .value("Series".localized, point.seriesTitle))
                .cornerRadius(4)
            } else {
                LineMark(
                    x: .value("Period".localized, point.label),
                    y: .value("Value".localized, point.value),
                    series: .value("Series".localized, point.seriesTitle)
                )
                .foregroundStyle(by: .value("Series".localized, point.seriesTitle))
                .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Period".localized, point.label),
                    y: .value("Value".localized, point.value)
                )
                .foregroundStyle(by: .value("Series".localized, point.seriesTitle))
                .symbolSize(36)
            }
        }
        .chartXScale(domain: orderedLabels)
        .chartYScale(domain: yDomain)
        .chartForegroundStyleScale { (seriesTitle: String) in color(forSeries: seriesTitle) }
        .chartLegend(showsLegend ? .visible : .hidden)
        .chartXAxis {
            AxisMarks(preset: .aligned, values: .automatic) { value in
                AxisValueLabel {
                    if let label = value.as(String.self) {
                        Text(label)
                            .font(LoginDesignSystem.Typography.lexendRegular(size: xLabelFontSize))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let raw = value.as(Double.self) {
                        Text(WearableMetricValueMapper.formattedNumber(raw))
                            .font(LoginDesignSystem.Typography.lexendRegular(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
    }

    // MARK: - Scales

    /// Bars always start at zero; lines get a padded window so small variations
    /// (heart rate 76 -> 80) stay readable instead of flattening onto the axis.
    private var yDomain: ClosedRange<Double> {
        let values = points.map(\.value).filter { $0.isFinite }
        guard let lowest = values.min(), let highest = values.max() else { return 0...1 }

        if useBars {
            let top = highest > 0 ? highest * 1.15 : 1
            return min(0, lowest)...top
        }

        guard highest > lowest else {
            let padding = max(abs(highest) * 0.1, 1)
            return (lowest - padding)...(highest + padding)
        }
        let padding = (highest - lowest) * 0.2
        return (lowest - padding)...(highest + padding)
    }

    private var seriesTitles: [String] {
        var seen: [String] = []
        for point in points where !seen.contains(point.seriesTitle) {
            seen.append(point.seriesTitle)
        }
        return seen
    }

    private static let palette: [Color] = [
        LoginDesignSystem.ColorName.primaryGradientTop,
        LoginDesignSystem.ColorName.coral,
        LoginDesignSystem.ColorName.linkBlue
    ]

    /// Stable colour per series: first series purple, second (diastolic) coral.
    private func color(forSeries title: String) -> Color {
        let index = seriesTitles.firstIndex(of: title) ?? 0
        return Self.palette[index % Self.palette.count]
    }

    private var xLabelFontSize: CGFloat { orderedLabels.count > 8 ? 9 : 11 }

    private var cardBackground: Color {
        if let uiColor = UIColor(named: "AppViewContentColor") {
            return Color(uiColor)
        }
        return Color(red: 0.984, green: 0.984, blue: 0.996)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Line chart card") {
    HealthMetricChartCardView(
        title: "Heart Rate - monthly average",
        points: [
            HealthMetricChartPoint(label: "JUL", seriesKey: .primary, seriesTitle: "Heart Rate", value: 79.79, valueText: "79.8 bpm"),
            HealthMetricChartPoint(label: "AUG", seriesKey: .primary, seriesTitle: "Heart Rate", value: 76.66, valueText: "76.7 bpm"),
        ],
        orderedLabels: ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"],
        useBars: false,
        showsLegend: false,
        emptyMessage: "No data available for this period."
    )
}
#endif
