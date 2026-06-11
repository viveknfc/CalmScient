//
//  ChartLineChartRepresentable.swift
//  Calmscient
//
//  DGCharts line chart bridge (chart view only — no table cell chrome).
//
//  Vivek
//  18 May 2026
//

import DGCharts
import SwiftUI

@available(iOS 16.0, *)
enum ChartLineChartMode {
    case mood
    case score
}

@available(iOS 16.0, *)
struct ChartLineChartRepresentable: UIViewRepresentable {
    let graphData: [GraphData]
    let mode: ChartLineChartMode

    func makeUIView(context: Context) -> LineChartView {
        WeeklySummaryChartConfigurator.makeLineChartView()
    }

    func updateUIView(_ chartView: LineChartView, context: Context) {
        switch mode {
        case .mood:
            WeeklySummaryChartConfigurator.configureMoodLineChart(chartView, graphData: graphData)
        case .score:
            WeeklySummaryChartConfigurator.configureScoreLineChart(chartView, graphData: graphData)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Line chart only") {
    ChartLineChartRepresentable(
        graphData: WeeklySummaryGraphPresentationPreviewData.sampleMoodGraphData,
        mode: .mood
    )
    .frame(height: WeeklySummaryChartConfigurator.chartContentHeight)
    .padding()
}
#endif
