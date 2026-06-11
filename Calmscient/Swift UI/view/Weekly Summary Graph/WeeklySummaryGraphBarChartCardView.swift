//
//  WeeklySummaryGraphBarChartCardView.swift
//  Calmscient
//
//  Bar chart section for weekly summary graphs (`ChartViewTableCellView`).
//
//  Vivek
//  18 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct WeeklySummaryGraphBarChartCardView: View {

    let title: String
    let graphData: [GraphData]

    var body: some View {
        ChartViewTableCellView(
            title: title,
            graphData: graphData,
            style: .bar
        )
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Mood bar chart card") {
    WeeklySummaryGraphBarChartCardView(
        title: "Days at each mood",
        graphData: WeeklySummaryGraphPresentationPreviewData.sampleMoodBarChartData
    )
}
#endif
