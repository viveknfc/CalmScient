//
//  ChartBarChartRepresentable.swift
//  Calmscient
//
//  DGCharts bar chart bridge (chart view only — no table cell chrome).
//
//  Vivek
//  18 May 2026
//

import DGCharts
import SwiftUI

@available(iOS 16.0, *)
struct ChartBarChartRepresentable: UIViewRepresentable {
    let graphData: [GraphData]

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> BarChartView {
        let chart = WeeklySummaryChartConfigurator.makeBarChartView()
        WeeklySummaryChartConfigurator.configureBarChart(chart, graphData: graphData, animated: false)
        context.coordinator.dataSignature = Self.signature(for: graphData)
        return chart
    }

    func updateUIView(_ chartView: BarChartView, context: Context) {
        let signature = Self.signature(for: graphData)
        guard context.coordinator.dataSignature != signature else { return }
        context.coordinator.dataSignature = signature
        WeeklySummaryChartConfigurator.configureBarChart(chartView, graphData: graphData)
    }

    private static func signature(for graphData: [GraphData]) -> String {
        graphData.map { "\($0.xValue):\($0.yValue)" }.joined(separator: "|")
    }

    final class Coordinator {
        var dataSignature: String?
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Bar chart only") {
    ChartBarChartRepresentable(
        graphData: WeeklySummaryGraphPresentationPreviewData.sampleMoodBarChartData
    )
    .frame(height: WeeklySummaryChartConfigurator.chartContentHeight)
    .padding()
}
#endif
