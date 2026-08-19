//
//  HealthMetricDetailViewModel.swift
//  Calmscient
//
//  Created by NFC Solutions on 11/08/26.
//

import Foundation
import SwiftUI
import UIKit

/// Backs the metric trend screen: a Weekly / Monthly / Yearly control over one chart.
///
/// This replaced a From/To/Go date-range form that listed one row per day. The chart is
/// fed by `wearable-data/average`, which buckets a whole period server-side — so the
/// screen no longer asks the user to pick two dates before it can show them anything, and
/// the client no longer aggregates day rows itself.
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

    /// Starts on the leading tab, as the Android screen does.
    @Published private(set) var period: HealthTrendPeriod = .weekly
    @Published private(set) var chart: HealthTrendChartData = .empty
    @Published private(set) var isLoading = false

    let dataSources: [HealthTrendDataSource] = HealthTrendDataSource.all
    @Published var selectedDataSourceId: String = HealthTrendDataSource.allSources.id

    var screenTitle: String { metric.titleKey.localized }
    var chartTitle: String { "\(metric.titleKey.localized) \("Trend".localized)" }
    var insightText: String { HealthMetricInsight.text(for: metric) }

    /// Set once a load has finished, so the first frame shows the spinner rather than the
    /// "no data" copy that an empty `chart` would otherwise trigger.
    @Published private(set) var hasLoadedOnce = false

    init(metric: HealthMetric) {
        self.metric = metric
    }

    private var patientId: Int? { ApplicationSharedInfo.shared.loginResponse?.patientID }
    private var accessToken: String? { ApplicationSharedInfo.shared.tokenResponse?.accessToken }

    /// Guards against the tab being tapped again while its request is in flight; without
    /// it a slow first response could land after a faster second one and win.
    private var inFlightPeriod: HealthTrendPeriod?

    // MARK: - Loading

    func onAppear() {
        guard !hasLoadedOnce else { return }
        load()
    }

    func select(period newPeriod: HealthTrendPeriod) {
        guard newPeriod != period else { return }
        period = newPeriod
        // Clear immediately: keeping the previous period's bars under the new tab's label
        // reads as data for a range it isn't.
        chart = .empty
        load()
    }

    func refresh() { load() }

    private func load() {
        guard let patientId, let token = accessToken, !token.isEmpty else { return }

        let requested = period
        inFlightPeriod = requested
        isLoading = true

        let params: [String: Any] = [
            "patientId": patientId,
            // Any date inside the period; the server expands it to the full week / month /
            // year and returns every bucket in that span.
            "date": Date().dateToString(format: "yyyy-MM-dd"),
            "period": requested.apiValue
        ]

        APIService.getWearableAverageAPICalling(
            hostViewController,
            params: params,
            accessToken: token
        ) { [weak self] response in
            Task { @MainActor in
                self?.handle(response, requested: requested)
            }
        }
    }

    // MARK: - Response handling

    private func handle(_ response: AnyObject, requested: HealthTrendPeriod) {
        // A response for a tab the user has already left is stale — drop it rather than
        // draw it under the current tab's heading.
        guard requested == period else { return }

        inFlightPeriod = nil
        isLoading = false
        hasLoadedOnce = true

        if let errorMessage = response as? String, errorMessage.hasPrefix("Error:") {
            chart = .empty
            hostViewController?.view.showToast(
                message: errorMessage.replacingOccurrences(of: "Error: ", with: ""))
            return
        }

        guard let json = response as? [String: Any],
              let data = try? JSONSerialization.data(withJSONObject: json),
              let decoded = try? JSONDecoder().decode(WearableAverageResponse.self, from: data) else {
            chart = .empty
            hostViewController?.view.showToast(
                message: "An Unknown error occured. Please check with Admin".localized)
            return
        }

        guard decoded.statusResponse.responseCode == 200 else {
            chart = .empty
            hostViewController?.view.showToast(message: decoded.statusResponse.responseMessage)
            return
        }

        chart = HealthTrendChartBuilder.make(from: decoded.data?.buckets ?? [], metric: metric)
    }

    // MARK: - Navigation

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

    /// Preview-only model with a dummy monthly series. Not used in release builds.
    static func previewModel(metricId: String = "heart_rate") -> HealthMetricDetailViewModel {
        let metric = HealthMetric.metric(for: metricId)!
        let vm = HealthMetricDetailViewModel(metric: metric)
        let labels = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
                      "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
        let points = labels.enumerated().map { index, label -> HealthTrendPoint in
            let value: Double? = index == 6 ? 79.79 : (index == 7 ? 58.4 : nil)
            return HealthTrendPoint(
                label: label,
                value: value,
                displayValue: value.map { String(Int($0.rounded())) } ?? "0",
                daysWithData: value == nil ? 0 : 24)
        }
        vm.chart = HealthTrendChartData(points: points,
                                        axisMaximum: 180,
                                        average: 69.1,
                                        averageText: "69 bpm")
        vm.hasLoadedOnce = true
        return vm
    }
}
#endif
