//
//  WeeklySummaryGraphPresentation.swift
//  Calmscient
//
//  Presentation models for weekly summary graph screens (parity with `WeeklySummaryGraphViewController`).
//
//  Vivek
//  18 May 2026
//

import Foundation

enum WeeklySummaryGraphSection: Identifiable {
    case dateRangeHeader
    case lineChart(title: String)
    case barChart(title: String)
    case sleepSummary(WeeklySummaryGraphSleepPresentation)

    var id: String {
        switch self {
        case .dateRangeHeader:
            return "dateRangeHeader"
        case .lineChart(let title):
            return "lineChart-\(title)"
        case .barChart(let title):
            return "barChart-\(title)"
        case .sleepSummary:
            return "sleepSummary"
        }
    }
}

struct WeeklySummaryGraphSleepPresentation: Equatable {
    let averageHoursText: String
    let averageHoursDenominator: String
    let progress: Float
    let mostHoursText: String
    let averageHoursDetailText: String
    let leastHoursText: String
}

enum WeeklySummaryGraphPresentationPreviewData {

    static let sampleMoodGraphData: [GraphData] = [
        GraphData(yAxisValue: 4, xAxisValue: "2026-05-10T10:00:00", additionalInfo: "GOOD", graphType: .WeeklySummarySummaryOfMood),
        GraphData(yAxisValue: 3, xAxisValue: "2026-05-12T10:00:00", additionalInfo: "FAIR", graphType: .WeeklySummarySummaryOfMood),
        GraphData(yAxisValue: 5, xAxisValue: "2026-05-14T10:00:00", additionalInfo: "EXCELLENT", graphType: .WeeklySummarySummaryOfMood),
    ]

    /// Aggregated mood counts for the “Days at each mood” bar chart preview.
    static let sampleMoodBarChartData: [GraphData] = [
        GraphData(yAxisValue: 2, xAxisValue: "1", additionalInfo: "BAD", graphType: .WeeklySummarySummaryOfMood),
        GraphData(yAxisValue: 1, xAxisValue: "2", additionalInfo: "COULD BE BETTER", graphType: .WeeklySummarySummaryOfMood),
        GraphData(yAxisValue: 3, xAxisValue: "3", additionalInfo: "FAIR", graphType: .WeeklySummarySummaryOfMood),
        GraphData(yAxisValue: 4, xAxisValue: "4", additionalInfo: "GOOD", graphType: .WeeklySummarySummaryOfMood),
        GraphData(yAxisValue: 2, xAxisValue: "5", additionalInfo: "EXCELLENT", graphType: .WeeklySummarySummaryOfMood),
    ]

    static let sampleSleepGraphData: [GraphData] = [
        GraphData(yAxisValue: 7, xAxisValue: "2026-05-10T10:00:00", additionalInfo: nil, graphType: .WeeklySummarySummaryOfSleep),
        GraphData(yAxisValue: 6, xAxisValue: "2026-05-12T10:00:00", additionalInfo: nil, graphType: .WeeklySummarySummaryOfSleep),
        GraphData(yAxisValue: 8, xAxisValue: "2026-05-14T10:00:00", additionalInfo: nil, graphType: .WeeklySummarySummaryOfSleep),
    ]

    static func sampleSleepSummary() -> WeeklySummaryGraphSleepPresentation {
        WeeklySummaryGraphSleepPresentation(
            averageHoursText: "7.00",
            averageHoursDenominator: "12",
            progress: 0.7,
            mostHoursText: "8 hrs",
            averageHoursDetailText: "7.00 hrs",
            leastHoursText: "6 hrs"
        )
    }
}
