//
//  WeeklySummaryGraphViewModel.swift
//  Calmscient
//
//  State, API, and navigation for weekly summary graph screens (parity with `WeeklySummaryGraphViewController`).
//
//  Vivek
//  18 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class WeeklySummaryGraphViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    private(set) var summaryType: WeeklySummaryItems = .WeeklySummarySummaryOfMood

    @Published private(set) var navigationChromeTitle: String = ""
    @Published private(set) var dateRangeText: String = ""
    @Published private(set) var sections: [WeeklySummaryGraphSection] = []
    @Published private(set) var chartData: [GraphData] = []
    @Published private(set) var barChartData: [GraphData] = []
    @Published private(set) var sleepSummary: WeeklySummaryGraphSleepPresentation?
    @Published private(set) var isLoading = false

    private(set) var needToTalkButtonTitle: String = ""
    private(set) var daysAtEachMoodTitle: String = ""
    private(set) var averageSleepScoreTitle: String = ""
    private(set) var mostHoursSleptTitle: String = ""
    private(set) var averageHoursSleptTitle: String = ""
    private(set) var leastHoursSleptTitle: String = ""

    private var dateRange: (fromDate: Date, toDate: Date) = (
        Date().getOlderDateWithDaysDifference(minusDays: -6),
        Date()
    )
    private let dateWindowDays = -6
    private var anchorView: UIView? { hostViewController?.view }
    private let datePickerPresenter = BottomSheetDatePickerPresenter()

    func configure(summaryType: WeeklySummaryItems) {
        self.summaryType = summaryType
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
        rebuildSections()
        fetchGraphData()
    }

    func reloadLocalizedStrings() {
        navigationChromeTitle = summaryType.localized
        needToTalkButtonTitle = "Need to talk with someone?".localized
        daysAtEachMoodTitle = "Days at each mood".localized
        averageSleepScoreTitle = AppHelper.getLocalizeString(str: "Average_sleep_score")
        mostHoursSleptTitle = AppHelper.getLocalizeString(str: "Most_hours_slept")
        averageHoursSleptTitle = AppHelper.getLocalizeString(str: "Average_hours_slept")
        leastHoursSleptTitle = AppHelper.getLocalizeString(str: "Least_hours_slept")
        updateDateRangeText()
    }

    func onNetworkRestored() {
        fetchGraphData()
    }

    func onNetworkLost() {
        anchorView?.hideToastActivity()
    }

    // MARK: - Navigation

    func openBack() {
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    func openNeedToTalk() {
        guard let nav = hostViewController?.navigationController else { return }
        let storyboard = UIStoryboard(name: "NeedToTalkViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NeedToTalkViewController") as? NeedToTalkViewController
        vc?.title = "Emergency resources".localized
        guard let vc else { return }
        nav.pushViewController(vc, animated: true)
    }

    func presentDatePicker() {
        guard let host = hostViewController else { return }

        datePickerPresenter.present(
            from: host,
            configuration: BottomSheetDatePickerConfiguration(
                pickerMode: .date,
                maximumDate: Date(),
                initialDate: dateRange.toDate
            )
        ) { [weak self] selectedDate, _ in
            guard let self else { return }
            let fromDate = selectedDate.getOlderDateWithDaysDifference(minusDays: self.dateWindowDays)
            self.dateRange = (fromDate, selectedDate)
            self.chartData = []
            self.barChartData = []
            self.sleepSummary = nil
            self.updateDateRangeText()
            self.rebuildSections()
            self.fetchGraphData()
        }
    }

    // MARK: - API

    func fetchGraphData() {
        guard NetworkMonitor.shared.isConnected else {
            NoInternetBanner.shared.openDetails()
            return
        }

        guard let host = hostViewController,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }

        isLoading = true
        rebuildSections()
        anchorView?.showToastActivity()

        let startDate = dateRange.fromDate.dateToString(format: "MM/dd/yyyy")
        let endDate = dateRange.toDate.dateToString(format: "MM/dd/yyyy")

        APIService.weeklySummaryGraphAPICalling(
            host,
            summaryItem: summaryType,
            startDate: startDate,
            endDate: endDate,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleFetchResponse(response)
            }
        }
    }

    private func handleFetchResponse(_ response: AnyObject) {
        isLoading = false
        anchorView?.hideToastActivity()

        if let errorMessage = response as? String, errorMessage.hasPrefix("Error:") {
            anchorView?.showToast(message: errorMessage.replacingOccurrences(of: "Error: ", with: ""))
            rebuildSections()
            return
        }

        guard let json = response as? [String: Any],
              let data = try? JSONSerialization.data(withJSONObject: json) else {
            anchorView?.showToast(message: "An Unknown error occured. Please check with Admin")
            rebuildSections()
            return
        }

        let parsed = summaryType.getGraphDataForWeeklySummary(responseData: data)
        chartData = parsed.0
        barChartData = prepareBarChartData(data: chartData)
        sleepSummary = buildSleepSummary(from: chartData)
        rebuildSections()
    }

    // MARK: - Sections

    private func rebuildSections() {
        var built: [WeeklySummaryGraphSection] = [.dateRangeHeader]

        let lineTitle = summaryType.graphTitle
        if !lineTitle.isEmpty {
            built.append(.lineChart(title: lineTitle))
        }

        switch summaryType {
        case .WeeklySummarySummaryOfMood:
            built.append(.barChart(title: daysAtEachMoodTitle))
        case .WeeklySummarySummaryOfSleep:
            if let sleepSummary {
                built.append(.sleepSummary(sleepSummary))
            } else {
                built.append(.sleepSummary(emptySleepSummary()))
            }
        default:
            break
        }

        sections = built
    }

    private func updateDateRangeText() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        dateRangeText = "\(formatter.string(from: dateRange.fromDate)) - \(formatter.string(from: dateRange.toDate))"
    }

    // MARK: - Chart data helpers

    private func prepareBarChartData(data: [GraphData]) -> [GraphData] {
        // Count by moodScore (1…5) so bar data is correct for every language (API mood text may be localized).
        let badCount = data.filter { $0.yValue == 1 }.count
        let couldBeBetterCount = data.filter { $0.yValue == 2 }.count
        let fairCount = data.filter { $0.yValue == 3 }.count
        let goodCount = data.filter { $0.yValue == 4 }.count
        let excellentCount = data.filter { $0.yValue == 5 }.count

        return [
            GraphData(yAxisValue: badCount, xAxisValue: "1", additionalInfo: "BAD", graphType: .WeeklySummarySummaryOfMood),
            GraphData(yAxisValue: couldBeBetterCount, xAxisValue: "2", additionalInfo: "COULD BE BETTER", graphType: .WeeklySummarySummaryOfMood),
            GraphData(yAxisValue: fairCount, xAxisValue: "3", additionalInfo: "FAIR", graphType: .WeeklySummarySummaryOfMood),
            GraphData(yAxisValue: goodCount, xAxisValue: "4", additionalInfo: "GOOD", graphType: .WeeklySummarySummaryOfMood),
            GraphData(yAxisValue: excellentCount, xAxisValue: "5", additionalInfo: "EXCELLENT", graphType: .WeeklySummarySummaryOfMood),
        ]
    }

    private func normalizeMood(_ value: String?) -> String? {
        guard let value = value?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased() else { return nil }

        switch value {
        case "excellent", "excelente":
            return "EXCELLENT"
        case "good", "bueno":
            return "GOOD"
        case "fair", "justo", "masomenos", "mas o menos":
            return "FAIR"
        case "could be better", "could be\nbetter", "podría ser mejor", "podría ser\nmejor", "podria ser mejor", "podria ser\nmejor":
            return "COULD BE BETTER"
        case "bad", "mal", "悪い":
            return "BAD"
        case "もっと良くしたい", "もう少し良くなれる":
            return "COULD BE BETTER"
        case "まあまあ":
            return "FAIR"
        case "良い":
            return "GOOD"
        case "とても良い", "素晴らしい":
            return "EXCELLENT"
        default:
            return nil
        }
    }

    private func buildSleepSummary(from chartData: [GraphData]) -> WeeklySummaryGraphSleepPresentation? {
        guard !chartData.isEmpty else { return nil }

        let sortedDescending = chartData.sorted { $0.yValue > $1.yValue }
        let nonZeroAscending = chartData.filter { $0.yValue > 0 }.sorted { $0.yValue < $1.yValue }
        let totalSleepHrs = chartData.map(\.yValue).reduce(0, +)
        let filteredForAverage = chartData.filter { $0.yValue > 0 }
        let average: Float = filteredForAverage.isEmpty
            ? 0
            : Float(totalSleepHrs) / Float(filteredForAverage.count)

        let mostText = sortedDescending.first.map { "\($0.yValue) hrs" } ?? "0 hrs"
        let leastText = nonZeroAscending.first.map { "\($0.yValue) hrs" } ?? "0 hrs"
        let averageDetail = String(format: "%.2f", average) + " hrs"
        let averagePrimary = String(format: "%.2f", average)

        return WeeklySummaryGraphSleepPresentation(
            averageHoursText: averagePrimary,
            averageHoursDenominator: "12",
            progress: average / 10.0,
            mostHoursText: mostText,
            averageHoursDetailText: averageDetail,
            leastHoursText: leastText
        )
    }

    private func emptySleepSummary() -> WeeklySummaryGraphSleepPresentation {
        WeeklySummaryGraphSleepPresentation(
            averageHoursText: "0",
            averageHoursDenominator: "12",
            progress: 0,
            mostHoursText: "0 hrs",
            averageHoursDetailText: "0 hrs",
            leastHoursText: "0 hrs"
        )
    }

    #if DEBUG
    func applyPreviewState(
        summaryType: WeeklySummaryItems,
        chartData: [GraphData],
        sleepSummary: WeeklySummaryGraphSleepPresentation? = nil
    ) {
        configure(summaryType: summaryType)
        reloadLocalizedStrings()
        self.chartData = chartData
        barChartData = prepareBarChartData(data: chartData)
        self.sleepSummary = sleepSummary ?? buildSleepSummary(from: chartData)
        rebuildSections()
    }
    #endif
}
