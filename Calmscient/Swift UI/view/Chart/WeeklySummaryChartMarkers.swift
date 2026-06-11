//
//  WeeklySummaryChartMarkers.swift
//  Calmscient
//
//  DGCharts balloon markers for weekly summary line and bar charts.
//
//  Vivek
//  18 May 2026
//

import DGCharts
import UIKit

public final class XYMarkerView: BalloonMarker {
    public var xAxisValueFormatter: MoodAxisFormatter
    public var yAxisFormatter: MoodValueAxisFormatter

    public init(
        color: UIColor,
        font: UIFont,
        textColor: UIColor,
        insets: UIEdgeInsets,
        xAxisValueFormatter: MoodAxisFormatter,
        yAxisFormatter: MoodValueAxisFormatter
    ) {
        self.xAxisValueFormatter = xAxisValueFormatter
        self.yAxisFormatter = yAxisFormatter
        super.init(color: color, font: font, textColor: textColor, insets: insets)
    }

    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let moodLabel = xAxisValueFormatter.stringForValue(entry.x, axis: XAxis()).lowercased()
        let string = "\(moodLabel): \(yAxisFormatter.stringForValue(entry.y, axis: YAxis())) Days"
        setLabel(string)
    }
}

public final class LineChartViewMarkerView: BalloonMarker {
    public var chartData: [GraphData]
    public var xAxisValueFormatter: XAxisLineChartFormatter

    public init(
        color: UIColor,
        font: UIFont,
        textColor: UIColor,
        insets: UIEdgeInsets,
        xAxisValueFormatter: XAxisLineChartFormatter,
        data: [GraphData]
    ) {
        self.xAxisValueFormatter = xAxisValueFormatter
        self.chartData = data
        super.init(color: color, font: font, textColor: textColor, insets: insets)
    }

    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let index = Int(entry.x)
        guard index >= 0, index < chartData.count else { return }
        setLabel(chartData[index].getMarkerTextValue())
    }
}
