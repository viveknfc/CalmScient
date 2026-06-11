//
//  WeeklySummaryGraphView.swift
//  Calmscient
//
//  SwiftUI weekly summary graph screen (parity with `WeeklySummaryGraphViewController`).
//
//  Vivek
//  18 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct WeeklySummaryGraphView: View {

    @ObservedObject var viewModel: WeeklySummaryGraphViewModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.sections) { section in
                        sectionView(section)
                    }
                }
                .padding(.bottom, 16)
            }

            if PatientLanguagePreference.shouldShowNeedToTalkButton() {
                LoginGradientButton(title: viewModel.needToTalkButtonTitle) {
                    viewModel.openNeedToTalk()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LoginDesignSystem.ColorName.pageBackground.ignoresSafeArea())
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    @ViewBuilder
    private func sectionView(_ section: WeeklySummaryGraphSection) -> some View {
        switch section {
        case .dateRangeHeader:
            WeeklySummaryGraphDateRangeHeaderView(
                dateRangeText: viewModel.dateRangeText,
                onCalendarTap: { viewModel.presentDatePicker() }
            )

        case .lineChart(let title):
            WeeklySummaryGraphLineChartCardView(
                title: title,
                graphData: viewModel.chartData,
                mode: viewModel.summaryType == .WeeklySummarySummaryOfMood ? .mood : .score
            )

        case .barChart(let title):
            WeeklySummaryGraphBarChartCardView(
                title: title,
                graphData: viewModel.barChartData
            )

        case .sleepSummary(let presentation):
            WeeklySummaryGraphSleepSummaryCardView(
                presentation: presentation,
                title: viewModel.averageSleepScoreTitle,
                mostHoursTitle: viewModel.mostHoursSleptTitle,
                averageHoursTitle: viewModel.averageHoursSleptTitle,
                leastHoursTitle: viewModel.leastHoursSleptTitle
            )
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Summary of mood graph") {
    let viewModel = WeeklySummaryGraphViewModel()
    viewModel.applyPreviewState(
        summaryType: .WeeklySummarySummaryOfMood,
        chartData: WeeklySummaryGraphPresentationPreviewData.sampleMoodGraphData
    )
    return WeeklySummaryGraphView(viewModel: viewModel)
}

@available(iOS 16.0, *)
#Preview("Summary of sleep graph") {
    let viewModel = WeeklySummaryGraphViewModel()
    viewModel.applyPreviewState(
        summaryType: .WeeklySummarySummaryOfSleep,
        chartData: WeeklySummaryGraphPresentationPreviewData.sampleSleepGraphData,
        sleepSummary: WeeklySummaryGraphPresentationPreviewData.sampleSleepSummary()
    )
    return WeeklySummaryGraphView(viewModel: viewModel)
}
#endif
