//
//  WeeklySummaryChartConfigurator.swift
//  Calmscient
//
//  Shared DGCharts setup for weekly summary line and bar charts (used by UIKit cell and SwiftUI).
//
//  Vivek
//  18 May 2026
//

import DGCharts
import UIKit

enum WeeklySummaryChartConfigurator {

    static let chartContentHeight: CGFloat = 279

    /// X-axis mood labels for the “Days at each mood” bar chart (and matching Y-axis on the mood line chart).
    enum MoodChartAxisLabels {
        static func label(forAxisValue value: Double) -> String {
            switch Int(value) {
            case 5: return localizedChartLabel(chartKey: "MoodChart_EXCELLENT", fallbackKey: "UserIntro_Mood_EXCELLENT")
            case 4: return localizedChartLabel(chartKey: "MoodChart_GOOD", fallbackKey: "UserIntro_Mood_GOOD")
            case 3: return localizedChartLabel(chartKey: "MoodChart_FAIR", fallbackKey: "UserIntro_Mood_FAIR")
            case 2: return localizedChartLabel(chartKey: "MoodChart_COULD_BE_BETTER", fallbackKey: "UserIntro_Mood_COULD_BE_BETTER", allowMultiline: true)
            case 1: return localizedChartLabel(chartKey: "MoodChart_BAD", fallbackKey: "UserIntro_Mood_BAD")
            default: return ""
            }
        }

        private static func localizedChartLabel(
            chartKey: String,
            fallbackKey: String,
            allowMultiline: Bool = false
        ) -> String {
            let chartText = AppHelper.getLocalizeString(str: chartKey)
            if chartText != chartKey, !chartText.isEmpty {
                return chartText
            }
            let moodText = AppHelper.getLocalizeString(str: fallbackKey)
            guard allowMultiline else { return moodText }
            return multilineChartLabel(from: moodText)
        }

        private static func multilineChartLabel(from text: String) -> String {
            if text.contains("\n") { return text }
            let words = text.split(separator: " ", omittingEmptySubsequences: true)
            guard words.count >= 2 else { return text }
            return words.dropLast().joined(separator: " ") + "\n" + words.last!
        }
    }

    private static func chartAxisFont(size: CGFloat) -> UIFont {
        UIFont(name: Fonts().lexendRegular, size: size) ?? .systemFont(ofSize: size)
    }

    static func makeLineChartView() -> LineChartView {
        let chart = LineChartView()
        chart.doubleTapToZoomEnabled = false
        chart.backgroundColor = UIColor(named: "AppViewContentColor")
        return chart
    }

    static func makeBarChartView() -> BarChartView {
        let chart = BarChartView()
        chart.doubleTapToZoomEnabled = false
        chart.backgroundColor = UIColor(named: "AppViewContentColor")
        return chart
    }

    static func configureMoodLineChart(_ lineChartView: LineChartView, graphData: [GraphData]) {
        guard graphData.count > 0 else {
            lineChartView.data = nil
            lineChartView.notifyDataSetChanged()
            lineChartView.noDataText = "No Data Found".localized
            lineChartView.animate(xAxisDuration: 0.01)
            return
        }

        lineChartView.legend.enabled = false
        lineChartView.xAxis.labelTextColor = UIColor(named: "lineChartLabelColor")!
        lineChartView.xAxis.valueFormatter = XAxisLineChartFormatter(graphData: graphData)
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.xAxis.drawGridLinesBehindDataEnabled = false
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.labelCount = graphData.count - 1
        lineChartView.xAxis.axisMinimum = 0
        lineChartView.xAxis.axisMaximum = Double(graphData.count - 1)
        lineChartView.rightAxis.enabled = false

        let leftAxis = lineChartView.leftAxis
        leftAxis.valueFormatter = MoodChartYAxisFormatter()
        leftAxis.labelFont = chartAxisFont(size: 12)
        leftAxis.labelTextColor = UIColor(named: "lineChartLabelColor")!
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawGridLinesEnabled = true
        leftAxis.zeroLineWidth = 0
        leftAxis.labelCount = 5
        leftAxis.axisMaximum = 5
        leftAxis.axisMinimum = 0
        leftAxis.gridLineDashLengths = [2, 2]
        leftAxis.drawBottomYLabelEntryEnabled = false

        let chartDataEntries = graphData.enumerated().map { index, datum in
            ChartDataEntry(x: Double(index), y: Double(datum.yValue))
        }

        let chartDataSet = LineChartDataSet(entries: chartDataEntries)
        chartDataSet.lineWidth = 2
        chartDataSet.colors = [UIColor(named: "lineChartViewLineColor")!]
        chartDataSet.circleColors = [UIColor.white]
        chartDataSet.circleRadius = 5
        chartDataSet.circleHoleColor = UIColor(named: "lineChartViewInternalCircleColor")
        chartDataSet.circleHoleRadius = 2
        chartDataSet.drawValuesEnabled = false
        lineChartView.data = LineChartData(dataSet: chartDataSet)

        let marker = LineChartViewMarkerView(
            color: UIColor(named: "chartsMarkerColor") ?? UIColor.lightGray,
            font: UIFont(name: Fonts().lexendRegular, size: 12)!,
            textColor: .black,
            insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
            xAxisValueFormatter: XAxisLineChartFormatter(graphData: graphData),
            data: graphData
        )
        marker.chartView = lineChartView
        marker.minimumSize = CGSize(width: 100, height: 45)
        lineChartView.fitScreen()
        lineChartView.extraRightOffset = 20
        lineChartView.extraLeftOffset = 10
        lineChartView.extraTopOffset = 30
        lineChartView.extraBottomOffset = 10
        lineChartView.animate(xAxisDuration: 2.5)
    }

    static func configureScoreLineChart(_ lineChartView: LineChartView, graphData: [GraphData]) {
        guard graphData.count > 0 else {
            lineChartView.data = nil
            lineChartView.notifyDataSetChanged()
            lineChartView.noDataText = "No Data Found".localized
            lineChartView.animate(xAxisDuration: 0.01)
            return
        }

        lineChartView.legend.enabled = false
        lineChartView.xAxis.labelTextColor = UIColor(named: "lineChartLabelColor")!
        lineChartView.xAxis.valueFormatter = XAxisLineChartFormatter(graphData: graphData)
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.xAxis.drawGridLinesBehindDataEnabled = false
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.labelCount = graphData.count
        lineChartView.xAxis.axisMinimum = 0
        lineChartView.xAxis.axisMaximum = Double(graphData.count - 1)
        lineChartView.xAxis.granularity = 1.0
        lineChartView.xAxis.granularityEnabled = true
        lineChartView.xAxis.forceLabelsEnabled = true
        lineChartView.rightAxis.enabled = false

        let leftAxis = lineChartView.leftAxis
        leftAxis.valueFormatter = ScoreAxisFormatter()
        leftAxis.labelTextColor = UIColor(named: "lineChartLabelColor")!
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawGridLinesEnabled = true
        leftAxis.zeroLineWidth = 0

        let maxYValue = graphData.map(\.yValue).max() ?? 0
        let granularity: Double
        if maxYValue > 20 {
            granularity = 3
        } else if maxYValue > 10 {
            granularity = 2
        } else {
            granularity = 1
        }

        leftAxis.granularity = granularity
        leftAxis.granularityEnabled = true
        let adjustedMaxY = ceil(Double(maxYValue) / granularity) * granularity
        leftAxis.axisMaximum = adjustedMaxY
        leftAxis.axisMinimum = 0
        leftAxis.labelCount = Int((adjustedMaxY / granularity) + 1)
        leftAxis.gridLineDashLengths = [2, 2]
        leftAxis.drawBottomYLabelEntryEnabled = false

        let chartDataEntries = graphData.enumerated().map { index, datum in
            ChartDataEntry(x: Double(index), y: Double(datum.yValue))
        }

        let chartDataSet = LineChartDataSet(entries: chartDataEntries)
        chartDataSet.lineWidth = 2
        chartDataSet.colors = [UIColor(named: "lineChartViewLineColor")!]
        chartDataSet.circleColors = [UIColor.white]
        chartDataSet.circleRadius = 5
        chartDataSet.circleHoleColor = UIColor(named: "lineChartViewInternalCircleColor")
        chartDataSet.circleHoleRadius = 2
        chartDataSet.drawValuesEnabled = false
        lineChartView.data = LineChartData(dataSet: chartDataSet)

        let marker = LineChartViewMarkerView(
            color: UIColor(named: "chartsMarkerColor") ?? UIColor.lightGray,
            font: UIFont(name: Fonts().lexendRegular, size: 12)!,
            textColor: .black,
            insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
            xAxisValueFormatter: XAxisLineChartFormatter(graphData: graphData),
            data: graphData
        )
        marker.chartView = lineChartView
        marker.minimumSize = CGSize(width: 100, height: 45)
        lineChartView.marker = marker
        lineChartView.fitScreen()
        lineChartView.extraRightOffset = 20
        lineChartView.extraLeftOffset = 20
        lineChartView.extraTopOffset = 30
        lineChartView.extraBottomOffset = 10
        lineChartView.animate(xAxisDuration: 2.5)
    }

    static func configureBarChart(_ barChartView: BarChartView, graphData: [GraphData], animated: Bool = true) {
        guard !graphData.isEmpty else {
            barChartView.data = nil
            barChartView.notifyDataSetChanged()
            barChartView.noDataText = "No Data Found".localized
            if animated {
                barChartView.animate(xAxisDuration: 0.01)
            }
            return
        }

        barChartView.drawBarShadowEnabled = false
        barChartView.drawValueAboveBarEnabled = false
        barChartView.legend.enabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.pinchZoomEnabled = false
        barChartView.fitBars = false

        let maxValue = graphData.map(\.yValue).max() ?? 0
        let yAxisMaximum = max(maxValue, 1)

        let leftAxis = barChartView.leftAxis
        leftAxis.labelFont = chartAxisFont(size: 12)
        leftAxis.labelTextColor = UIColor(named: "lineChartLabelColor")!
        leftAxis.drawAxisLineEnabled = false
        leftAxis.labelCount = maxValue > 0 ? maxValue : 2
        leftAxis.axisMaximum = Double(yAxisMaximum)
        leftAxis.valueFormatter = MoodValueAxisFormatter()
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0

        barChartView.rightAxis.enabled = false

        let xAxis = barChartView.xAxis
        xAxis.drawGridLinesEnabled = false
        xAxis.labelTextColor = UIColor(named: "lineChartLabelColor")!
        xAxis.drawAxisLineEnabled = false
        xAxis.labelCount = graphData.count
        xAxis.labelPosition = .bottom
        xAxis.labelFont = chartAxisFont(size: 10)
        xAxis.valueFormatter = MoodAxisFormatter()
        // Bars and labels both use x = 1…5 (mood scores).
        xAxis.axisMinimum = 1
        xAxis.axisMaximum = Double(graphData.count)
        xAxis.centerAxisLabelsEnabled = false
        xAxis.granularity = 1
        xAxis.granularityEnabled = true
        xAxis.forceLabelsEnabled = true

        barChartView.extraBottomOffset = 28

        let colors = [
            UIColor(named: "barColor1")!,
            UIColor(named: "barColor2")!,
            UIColor(named: "barColor3")!,
            UIColor(named: "barColor4")!,
            UIColor(named: "barColor5")!,
        ]
        let entries = graphData.enumerated().map { index, value in
            BarChartDataEntry(x: Double(index + 1), y: Double(value.yValue))
        }

        let dataset = BarChartDataSet(entries: entries)
        dataset.colors = colors

        let barChartData = BarChartData(dataSet: dataset)
        barChartData.barWidth = 0.5
        barChartView.data = barChartData
        barChartView.data?.setDrawValues(false)
        barChartView.isUserInteractionEnabled = false
        barChartView.notifyDataSetChanged()
        if animated {
            barChartView.animate(yAxisDuration: 2)
        }
    }
}
