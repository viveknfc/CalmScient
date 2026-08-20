//
//  HealthMetricDetailViewModel.swift
//  Calmscient
//
//  Created by NFC Solutions on 11/08/26.
//
//  Drives the health metric detail screen: Week / Month / Year tabs backed by
//  `GET patients/api/v1/health/wearable-data/average`, a chart of the returned
//  buckets and on-device insights.
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class HealthMetricDetailViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    // MARK: - SwiftUI navigation
    //
    // Set by `HomeTabView` when this screen is shown inside the Home `NavigationStack`.
    // While nil, every call below falls through to the existing UIKit push/pop, which is
    // what the still-UIKit Discovery tab uses when it pushes into these screens.
    var onOpenRoute: ((HomeRoute) -> Void)?
    var onClose: (() -> Void)?
    var onCloseToRoot: (() -> Void)?

    let metric: HealthMetric

    /// Tabs, in display order.
    let periods = HealthMetricAveragePeriod.allCases

    @Published private(set) var selectedPeriod: HealthMetricAveragePeriod = .week
    @Published private(set) var points: [HealthMetricChartPoint] = []
    /// Every bucket label of the period, in order — empty buckets stay on the axis.
    @Published private(set) var orderedLabels: [String] = []
    @Published private(set) var insights: [HealthMetricInsight] = []
    @Published private(set) var periodRangeText = ""
    @Published private(set) var isLoading = false
    @Published private(set) var hasLoaded = false

    var screenTitle: String { metric.titleKey.localized }

    /// "Heart Rate - Daily average"
    var chartTitle: String {
        "\(metric.titleKey.localized) - \(averageDescription)"
    }

    private var averageDescription: String {
        switch selectedPeriod {
        case .week:  return "Daily average".localized
        case .month: return "Monthly average".localized
        case .year:  return "Yearly average".localized
        }
    }

    /// Bars for cumulative metrics (steps, calories, hydration), line for discrete ones.
    var useBars: Bool {
        switch metric.aggregation {
        case .cumulativeSum:
            return true
        case .discreteAverage, .discreteMostRecent:
            return false
        }
    }

    /// Only blood pressure plots more than one series, so only it needs a legend.
    var showsLegend: Bool { metric.id == Self.bloodPressureMetricId }

    var isEmpty: Bool { points.isEmpty }

    init(metric: HealthMetric) {
        self.metric = metric
    }

    private var patientId: Int? { ApplicationSharedInfo.shared.loginResponse?.patientID }
    private var accessToken: String? { ApplicationSharedInfo.shared.tokenResponse?.accessToken }

    private static let bloodPressureMetricId = "blood_pressure"

    /// Guards against a slower earlier tab overwriting a newer one.
    private var requestId = 0

    // MARK: - Loading

    func loadIfNeeded() {
        guard !hasLoaded, !isLoading else { return }
        load()
    }

    func select(_ period: HealthMetricAveragePeriod) {
        guard period != selectedPeriod else {
            // Re-tapping the active tab retries a load that failed or came back empty.
            if points.isEmpty && !isLoading { load() }
            return
        }
        selectedPeriod = period
        load()
    }

    func reload() {
        load()
    }

    private func load() {
        guard let patientId, let accessToken else {
            applyEmptyState()
            hasLoaded = true
            hostViewController?.view.showToast(message: "An Unknown error occured. Please check with Admin".localized)
            return
        }

        requestId += 1
        let currentRequestId = requestId
        // Only the very first load blocks the screen; tab switches keep the old
        // chart on screen under an inline spinner.
        let showsBlockingSpinner = !hasLoaded

        isLoading = true
        if showsBlockingSpinner { hostViewController?.view.showToastActivity() }

        let params: [String: Any] = [
            "patientId": patientId,
            "date": Date().dateToString(format: "yyyy-MM-dd"),
            "period": selectedPeriod.rawValue
        ]

        APIService.getWearableDataAverageAPICalling(
            hostViewController,
            params: params,
            accessToken: accessToken
        ) { [weak self] response in
            Task { @MainActor in
                guard let self, currentRequestId == self.requestId else { return }
                if showsBlockingSpinner { self.hostViewController?.view.hideToastActivity() }
                self.handle(response)
            }
        }
    }

    // MARK: - Response handling

    private func handle(_ response: AnyObject) {
        isLoading = false
        hasLoaded = true

        if let errorMessage = response as? String, errorMessage.hasPrefix("Error:") {
            applyEmptyState()
            hostViewController?.view.showToast(message: errorMessage.replacingOccurrences(of: "Error: ", with: ""))
            return
        }

        guard let json = response as? [String: Any],
              let data = try? JSONSerialization.data(withJSONObject: json),
              let decoded = try? JSONDecoder().decode(WearableDataAverageResponse.self, from: data) else {
            applyEmptyState()
            hostViewController?.view.showToast(message: "An Unknown error occured. Please check with Admin".localized)
            return
        }

        guard decoded.statusResponse.responseCode == 200 else {
            applyEmptyState()
            hostViewController?.view.showToast(message: decoded.statusResponse.responseMessage)
            return
        }

        apply(decoded.data)
    }

    private func applyEmptyState() {
        points = []
        orderedLabels = []
        insights = []
        periodRangeText = ""
        isLoading = false
    }

    private func apply(_ data: WearableAverageData?) {
        let buckets = data?.buckets ?? []

        var labels: [String] = []
        var chartPoints: [HealthMetricChartPoint] = []

        for bucket in buckets {
            guard let label = bucket.label, !label.isEmpty else { continue }
            // Axis labels stay unique; a repeated label still contributes its values.
            if !labels.contains(label) { labels.append(label) }

            for series in WearableMetricValueMapper.seriesValues(for: metric, in: bucket) {
                chartPoints.append(
                    HealthMetricChartPoint(
                        label: label,
                        seriesKey: series.seriesKey,
                        seriesTitle: seriesTitle(for: series.seriesKey),
                        value: series.value,
                        valueText: WearableMetricValueMapper.formatted(series.value, for: metric)
                    )
                )
            }
        }

        orderedLabels = labels
        points = chartPoints
        periodRangeText = Self.rangeText(start: data?.startDate, end: data?.endDate)
        insights = makeInsights(from: buckets)
    }

    private func seriesTitle(for key: HealthMetricChartSeriesKey) -> String {
        guard let titleKey = key.titleKey else { return metric.titleKey.localized }
        return titleKey.localized
    }

    // MARK: - Insights (derived on device — the API returns no insight text)

    private func makeInsights(from buckets: [WearableAverageBucket]) -> [HealthMetricInsight] {
        guard !points.isEmpty else { return [] }

        var result: [HealthMetricInsight] = []

        if metric.id == Self.bloodPressureMetricId {
            let systolic = stats(for: .systolic)
            let diastolic = stats(for: .diastolic)

            if let systolicAverage = systolic?.average, let diastolicAverage = diastolic?.average {
                result.append(HealthMetricInsight(
                    title: "Average".localized,
                    valueText: "\(WearableMetricValueMapper.formattedNumber(systolicAverage))/\(WearableMetricValueMapper.formattedNumber(diastolicAverage)) \(metric.unit)"))
            }
            if let systolic {
                result.append(HealthMetricInsight(
                    title: "Highest systolic".localized,
                    valueText: labelledValue(systolic.highest)))
                result.append(HealthMetricInsight(
                    title: "Lowest systolic".localized,
                    valueText: labelledValue(systolic.lowest)))
            }
            if let diastolic {
                result.append(HealthMetricInsight(
                    title: "Highest diastolic".localized,
                    valueText: labelledValue(diastolic.highest)))
                result.append(HealthMetricInsight(
                    title: "Lowest diastolic".localized,
                    valueText: labelledValue(diastolic.lowest)))
            }
        } else if let summary = stats(for: .primary) {
            result.append(HealthMetricInsight(
                title: "Average".localized,
                valueText: WearableMetricValueMapper.formatted(summary.average, for: metric)))
            result.append(HealthMetricInsight(
                title: "Highest".localized,
                valueText: labelledValue(summary.highest)))
            result.append(HealthMetricInsight(
                title: "Lowest".localized,
                valueText: labelledValue(summary.lowest)))

            if let change = summary.change {
                result.append(HealthMetricInsight(
                    title: "Change".localized,
                    valueText: change))
            }
        }

        let daysWithData = buckets.reduce(0) { $0 + ($1.daysWithData ?? 0) }
        if daysWithData > 0 {
            result.append(HealthMetricInsight(
                title: "Days with data".localized,
                valueText: "\(daysWithData)"))
        }

        return result
    }

    private struct SeriesStats {
        let average: Double
        let highest: HealthMetricChartPoint
        let lowest: HealthMetricChartPoint
        let change: String?
    }

    private func stats(for key: HealthMetricChartSeriesKey) -> SeriesStats? {
        let seriesPoints = points.filter { $0.seriesKey == key }
        guard !seriesPoints.isEmpty,
              let highest = seriesPoints.max(by: { $0.value < $1.value }),
              let lowest = seriesPoints.min(by: { $0.value < $1.value }) else { return nil }

        let total = seriesPoints.reduce(0) { $0 + $1.value }
        let average = total / Double(seriesPoints.count)

        var change: String?
        if seriesPoints.count >= 2 {
            let latest = seriesPoints[seriesPoints.count - 1]
            let previous = seriesPoints[seriesPoints.count - 2]
            let delta = latest.value - previous.value
            let sign = delta > 0 ? "+" : (delta < 0 ? "-" : "")
            let magnitude = WearableMetricValueMapper.formatted(abs(delta), for: metric)
            change = "\(sign)\(magnitude) \("vs".localized) \(previous.label)"
        }

        return SeriesStats(average: average, highest: highest, lowest: lowest, change: change)
    }

    private func labelledValue(_ point: HealthMetricChartPoint) -> String {
        "\(point.valueText) (\(point.label))"
    }

    // MARK: - Formatting

    /// "2026-01-01", "2026-12-31" -> "01 Jan 2026 - 31 Dec 2026"
    private static func rangeText(start: String?, end: String?) -> String {
        let startText = headerLabel(from: start)
        let endText = headerLabel(from: end)
        switch (startText, endText) {
        case let (start?, end?) where start != end: return "\(start) - \(end)"
        case let (start?, _): return start
        case let (_, end?): return end
        default: return ""
        }
    }

    /// "2026-07-19" -> "19 Jul 2026" (falls back to the raw string).
    private static func headerLabel(from apiDate: String?) -> String? {
        guard let apiDate, !apiDate.isEmpty else { return nil }

        let input = DateFormatter()
        input.dateFormat = "yyyy-MM-dd"
        input.timeZone = TimeZone(identifier: Calendar.current.timeZone.identifier)
        guard let date = input.date(from: apiDate) else { return apiDate }

        let output = DateFormatter()
        output.dateFormat = "dd MMM yyyy"
        output.timeZone = TimeZone(identifier: Calendar.current.timeZone.identifier)
        return output.string(from: date)
    }

    func openBack() {
        if let onClose {
            onClose()
            return
        }
        hostViewController?.navigationController?.popViewController(animated: true)
    }
}

#if DEBUG
@available(iOS 16.0, *)
extension HealthMetricDetailViewModel {

    /// Preview-only model with dummy buckets. Not used in release builds.
    static func previewModel(metricId: String = "heart_rate") -> HealthMetricDetailViewModel {
        let metric = HealthMetric.metric(for: metricId) ?? HealthMetric.all[0]
        let viewModel = HealthMetricDetailViewModel(metric: metric)
        viewModel.orderedLabels = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
        viewModel.points = [
            HealthMetricChartPoint(label: "MON", seriesKey: .primary, seriesTitle: metric.titleKey,
                                   value: 78.2, valueText: "78.2 bpm"),
            HealthMetricChartPoint(label: "TUE", seriesKey: .primary, seriesTitle: metric.titleKey,
                                   value: 81.4, valueText: "81.4 bpm"),
            HealthMetricChartPoint(label: "WED", seriesKey: .primary, seriesTitle: metric.titleKey,
                                   value: 76.9, valueText: "76.9 bpm"),
        ]
        viewModel.insights = [
            HealthMetricInsight(title: "Average", valueText: "78.8 bpm"),
            HealthMetricInsight(title: "Highest", valueText: "81.4 bpm (TUE)"),
            HealthMetricInsight(title: "Lowest", valueText: "76.9 bpm (WED)"),
        ]
        viewModel.periodRangeText = "17 Aug 2026 - 23 Aug 2026"
        viewModel.hasLoaded = true
        return viewModel
    }
}
#endif
