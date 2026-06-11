//
//  WeeklySummaryGraphLineChartCardView.swift
//  Calmscient
//
//  Line chart section for weekly summary graphs (`ChartViewTableCellView`).
//
//  Vivek
//  18 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct WeeklySummaryGraphLineChartCardView: View {

    let title: String
    let graphData: [GraphData]
    let mode: ChartLineChartMode

    var body: some View {
        ChartViewTableCellView(
            title: title,
            graphData: graphData,
            style: mode == .mood ? .moodLine : .scoreLine
        )
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Mood line chart card") {
    WeeklySummaryGraphLineChartCardView(
        title: "Mood by date range",
        graphData: WeeklySummaryGraphPresentationPreviewData.sampleMoodGraphData,
        mode: .mood
    )
}
#endif
