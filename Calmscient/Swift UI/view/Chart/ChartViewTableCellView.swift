//
//  ChartViewTableCellView.swift
//  Calmscient
//
//  SwiftUI replacement for `ChartViewTableCell` (title + shadow card + chart, tight layout).
//
//  Vivek
//  18 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
enum ChartViewTableCellStyle {
    case moodLine
    case scoreLine
    case bar
}

@available(iOS 16.0, *)
struct ChartViewTableCellView: View {

    let title: String
    let graphData: [GraphData]
    let style: ChartViewTableCellStyle

    private let horizontalInset: CGFloat = 16
    private let titleTopInset: CGFloat = 12
    private let titleToChartSpacing: CGFloat = 16
    private let cardBottomInset: CGFloat = 8

    var body: some View {
        VStack(alignment: .leading, spacing: titleToChartSpacing) {
            Text(title)
                .font(.custom(Fonts().lexendRegular, size: 16))
                .foregroundStyle(Color.primary)
                .padding(.horizontal, horizontalInset)
                .padding(.top, titleTopInset)

            chartCard
                .padding(.horizontal, horizontalInset)
                .padding(.bottom, cardBottomInset)
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
        }
    }

    @ViewBuilder
    private var chartCard: some View {
        Group {
            switch style {
            case .moodLine:
                ChartLineChartRepresentable(graphData: graphData, mode: .mood)
            case .scoreLine:
                ChartLineChartRepresentable(graphData: graphData, mode: .score)
            case .bar:
                ChartBarChartRepresentable(graphData: graphData)
            }
        }
        .frame(height: WeeklySummaryChartConfigurator.chartContentHeight)
        .frame(maxWidth: .infinity)
        .background(chartCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
    }

    private var chartCardBackground: Color {
        if let uiColor = UIColor(named: "AppViewContentColor") {
            return Color(uiColor)
        }
        return Color(red: 0.984, green: 0.984, blue: 0.996)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Mood line chart cell") {
    ChartViewTableCellView(
        title: "Mood by date range",
        graphData: WeeklySummaryGraphPresentationPreviewData.sampleMoodGraphData,
        style: .moodLine
    )
}

@available(iOS 16.0, *)
#Preview("Bar chart cell") {
    ChartViewTableCellView(
        title: "Days at each mood",
        graphData: WeeklySummaryGraphPresentationPreviewData.sampleMoodBarChartData,
        style: .bar
    )
}
#endif
