//
//  WeeklySummaryChartFormatters.swift
//  Calmscient
//
//  DGCharts axis value formatters for weekly summary mood and score charts.
//
//  Vivek
//  18 May 2026
//

import DGCharts
import Foundation

public final class MoodAxisFormatter: AxisValueFormatter {
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        WeeklySummaryChartConfigurator.MoodChartAxisLabels.label(forAxisValue: Double(Int(round(value))))
    }
}

public final class MoodValueAxisFormatter: AxisValueFormatter {
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        "\(Int(value))"
    }
}

public final class MoodChartYAxisFormatter: AxisValueFormatter {
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let label = WeeklySummaryChartConfigurator.MoodChartAxisLabels.label(forAxisValue: Double(Int(round(value))))
        return label.isEmpty ? "N/A" : label
    }
}

public final class XAxisLineChartFormatter: AxisValueFormatter {
    private let graphData: [GraphData]

    init(graphData: [GraphData]) {
        self.graphData = graphData
    }

    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(round(value))
        guard index >= 0, index < graphData.count else { return "" }
        return graphData[index].getXAxisLabelValue()
    }
}

public final class ScoreAxisFormatter: AxisValueFormatter {
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        "\(Int(value))"
    }
}
