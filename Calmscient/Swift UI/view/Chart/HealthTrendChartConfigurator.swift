//
//  HealthTrendChartConfigurator.swift
//  Calmscient
//
//  DGCharts setup + SwiftUI bridge for the metric trend bar chart (Health Metrics detail).
//
//  Created by NFC Solutions on 19/08/26.
//

import DGCharts
import SwiftUI
import UIKit

// MARK: - Axis / value formatters

/// Prints the server's own bucket labels ("MON", "JAN", "2026") under each bar, looked up
/// by index — the x values are plain 0…n positions, not dates, so the label list is the
/// only thing that knows what a bar means.
public final class HealthTrendXAxisFormatter: AxisValueFormatter {
    private let labels: [String]

    init(labels: [String]) { self.labels = labels }

    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value.rounded())
        guard labels.indices.contains(index) else { return "" }
        return labels[index]
    }
}

/// `0.0` and `45.0` but `135` and `180` — the ladder the Android chart draws, which keeps
/// the decimal only while the number is narrow enough to need it for alignment.
public final class HealthTrendYAxisFormatter: AxisValueFormatter {
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        value < 100 ? String(format: "%.1f", value) : String(Int(value.rounded()))
    }
}

/// Prints each bucket's pre-formatted text above its bar.
///
/// Not derived from the plotted `y`: an empty bucket plots 0 but its label is the string
/// the presentation layer already decided on, and a real value keeps the rounding the
/// metric's unit calls for rather than DGCharts' default one-decimal.
public final class HealthTrendBarValueFormatter: ValueFormatter {
    private let texts: [String]

    init(texts: [String]) { self.texts = texts }

    public func stringForValue(_ value: Double,
                               entry: ChartDataEntry,
                               dataSetIndex: Int,
                               viewPortHandler: ViewPortHandler?) -> String {
        let index = Int(entry.x.rounded())
        guard texts.indices.contains(index) else { return "" }
        return texts[index]
    }
}

// MARK: - Chart configuration

enum HealthTrendChartConfigurator {

    static let chartContentHeight: CGFloat = 210

    /// `#6D6BB3`, the same brand purple as the calendar's Search button.
    static let brandPurple = UIColor(hex: "#6D6BB3")
    /// `#2C3349`, used for the baseline the empty buckets sit on.
    static let baselineColor = UIColor(hex: "#2C3349")

    private static func chartFont(_ size: CGFloat) -> UIFont {
        UIFont(name: Fonts().lexendRegular, size: size) ?? .systemFont(ofSize: size)
    }

    private static func chartMediumFont(_ size: CGFloat) -> UIFont {
        UIFont(name: Fonts().lexendMedium, size: size) ?? .systemFont(ofSize: size, weight: .medium)
    }

    static func makeBarChartView() -> BarChartView {
        let chart = BarChartView()
        chart.backgroundColor = .clear
        chart.legend.enabled = false
        chart.doubleTapToZoomEnabled = false
        chart.pinchZoomEnabled = false
        chart.scaleXEnabled = false
        chart.scaleYEnabled = false
        chart.highlightPerTapEnabled = false
        chart.highlightPerDragEnabled = false
        chart.noDataText = "No data for this period.".localized
        chart.noDataFont = chartFont(13)
        chart.noDataTextColor = .secondaryLabel
        return chart
    }

    static func configure(_ chart: BarChartView,
                          data: HealthTrendChartData,
                          animated: Bool = true) {

        guard !data.points.isEmpty else {
            chart.data = nil
            chart.rightAxis.removeAllLimitLines()
            chart.notifyDataSetChanged()
            return
        }

        // Value labels sit above the bars, so they need headroom that the axis maximum
        // alone doesn't give them.
        chart.drawValueAboveBarEnabled = true
        chart.drawBarShadowEnabled = false
        // No `fitBars`: it only pads the x-range when the axis range is data-derived, and
        // `configureXAxis` sets an explicit min/max (which flips DGCharts' custom-range
        // flags and wins in `AxisBase.calculate`). Leaving it on would read as if it were
        // doing the padding that the explicit -0.5 … n-0.5 range actually does.
        chart.extraTopOffset = 16
        chart.extraBottomOffset = 6
        chart.extraRightOffset = 8

        configureYAxis(chart, data: data)
        configureXAxis(chart, data: data)
        chart.data = makeBarData(from: data)
        chart.notifyDataSetChanged()

        if animated {
            chart.animate(yAxisDuration: 0.8, easingOption: .easeOutCubic)
        }
    }

    // MARK: - Axes

    /// Labels live on the trailing edge, matching the Android chart. The left axis is off
    /// entirely rather than merely unlabelled, so it claims no width.
    private static func configureYAxis(_ chart: BarChartView, data: HealthTrendChartData) {
        chart.leftAxis.enabled = false

        let axis = chart.rightAxis
        axis.enabled = true
        axis.axisMinimum = 0
        axis.axisMaximum = data.axisMaximum
        // Five forced labels give the 0 / ¼ / ½ / ¾ / max ladder. Without `forceLabels`
        // DGCharts treats `labelCount` as a hint and picks its own round numbers, which
        // drifts the gridlines away from the quarters the bars are scaled against.
        axis.labelCount = 5
        axis.forceLabelsEnabled = true
        axis.labelPosition = .outsideChart
        axis.valueFormatter = HealthTrendYAxisFormatter()
        axis.labelFont = chartFont(11)
        axis.labelTextColor = .secondaryLabel
        axis.drawAxisLineEnabled = false
        axis.drawGridLinesEnabled = true
        axis.gridColor = UIColor.separator.withAlphaComponent(0.35)
        axis.gridLineWidth = 1

        // The dark line the empty buckets rest on.
        axis.drawZeroLineEnabled = true
        axis.zeroLineColor = baselineColor
        axis.zeroLineWidth = 1.5

        // Dashed period average. Cleared first: limit lines persist across reconfigures,
        // so switching tabs would otherwise stack one line per period visited.
        axis.removeAllLimitLines()
        if let average = data.average {
            let line = ChartLimitLine(limit: average)
            line.lineWidth = 1
            line.lineDashLengths = [4, 4]
            line.lineColor = brandPurple.withAlphaComponent(0.45)
            line.drawLabelEnabled = false
            axis.addLimitLine(line)
        }
    }

    private static func configureXAxis(_ chart: BarChartView, data: HealthTrendChartData) {
        let axis = chart.xAxis
        axis.labelPosition = .bottom
        axis.drawGridLinesEnabled = false
        axis.drawAxisLineEnabled = false
        axis.valueFormatter = HealthTrendXAxisFormatter(labels: data.points.map(\.label))
        axis.labelFont = chartFont(10)
        axis.labelTextColor = .secondaryLabel
        axis.granularity = 1
        axis.granularityEnabled = true
        axis.forceLabelsEnabled = true
        axis.labelCount = data.points.count
        // Half a slot of padding at each end so the first and last bars aren't clipped
        // against the plot edge.
        axis.axisMinimum = -0.5
        axis.axisMaximum = Double(data.points.count) - 0.5
    }

    // MARK: - Data set

    private static func makeBarData(from data: HealthTrendChartData) -> BarChartData {
        let entries = data.points.enumerated().map { index, point in
            BarChartDataEntry(x: Double(index), y: point.plottedValue)
        }

        let dataSet = BarChartDataSet(entries: entries)
        // `colors` and `valueColors` are indexed per entry, which is what lets an empty
        // bucket render as a bare grey "0" on the baseline while a real one gets a purple
        // bar — one data set, two appearances, no second series to keep in step.
        dataSet.colors = data.points.map { $0.hasData ? brandPurple : .clear }
        dataSet.valueColors = data.points.map { $0.hasData ? brandPurple : UIColor.secondaryLabel }
        dataSet.drawValuesEnabled = true
        dataSet.valueFont = chartMediumFont(11)
        dataSet.valueFormatter = HealthTrendBarValueFormatter(texts: data.points.map(\.displayValue))
        dataSet.highlightEnabled = false

        let barData = BarChartData(dataSet: dataSet)
        // Twelve monthly buckets need thinner bars than seven daily ones to keep the same
        // gap between them.
        barData.barWidth = data.points.count > 8 ? 0.34 : 0.45
        return barData
    }
}

// MARK: - SwiftUI bridge

/// Mirrors `ChartBarChartRepresentable`: rebuild only when the values actually change, so
/// SwiftUI's frequent re-evaluations don't restart the bar animation on every layout pass.
@available(iOS 16.0, *)
struct HealthTrendChartRepresentable: UIViewRepresentable {

    let data: HealthTrendChartData

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> BarChartView {
        let chart = HealthTrendChartConfigurator.makeBarChartView()
        HealthTrendChartConfigurator.configure(chart, data: data, animated: false)
        context.coordinator.dataSignature = Self.signature(for: data)
        return chart
    }

    func updateUIView(_ chart: BarChartView, context: Context) {
        let signature = Self.signature(for: data)
        guard context.coordinator.dataSignature != signature else { return }
        context.coordinator.dataSignature = signature
        HealthTrendChartConfigurator.configure(chart, data: data)
    }

    private static func signature(for data: HealthTrendChartData) -> String {
        let points: [String] = data.points.map { point in
            let value = point.value.map { String($0) } ?? "-"
            return "\(point.label):\(value)"
        }
        let average = data.average.map { String($0) } ?? "-"
        return "\(points.joined(separator: "|"))#\(data.axisMaximum)#\(average)"
    }

    final class Coordinator {
        var dataSignature: String?
    }
}
