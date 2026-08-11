//
//  HealthMetricsViewModel.swift
//  Calmscient
//
//  State + navigation for the Health Metrics dashboard. Requests HealthKit
//  authorization and loads the current value for every metric in the catalog.
//
//  11 August 2026
//

import SwiftUI
import UIKit
import Combine

@available(iOS 16.0, *)
@MainActor
final class HealthMetricsViewModel: ObservableObject {

    /// A metric plus its current formatted value for display in a row.
    struct Row: Identifiable {
        let metric: HealthMetricType
        var value: String
        var id: String { metric.rawValue }
    }

    /// A category header with its rows.
    struct Section: Identifiable {
        let category: HealthCategory
        var rows: [Row]
        var id: String { category.rawValue }
    }

    weak var hostViewController: UIViewController?

    let screenTitle = "Health Metrics"

    @Published private(set) var sections: [Section] = []
    @Published private(set) var isLoading = false
    @Published private(set) var authorizationDenied = false

    private let repository = HealthMetricsRepository.shared

    /// Formatted values read from HealthKit on the phone, keyed by metric rawValue.
    private var healthKitValues: [String: String] = [:]
    /// Values pushed from the Apple Watch (display units), keyed by metric rawValue.
    private var watchValues: [String: Double] = [:]
    private var cancellables = Set<AnyCancellable>()

    init() {
        rebuildRows()
        // Apply the last snapshot the watch already sent, and observe future ones.
        if let existing = PhoneConnectivityManager.shared.lastHealthSnapshot {
            watchValues = existing.values
            rebuildRows()
        }
        PhoneConnectivityManager.shared.$lastHealthSnapshot
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] snapshot in
                self?.applyWatchSnapshot(snapshot)
            }
            .store(in: &cancellables)
    }

    /// Rebuilds the section/row list, preferring watch-provided values over the
    /// phone's HealthKit reads when the watch has sent that metric.
    private func rebuildRows() {
        sections = HealthCategory.allCases.map { category in
            let rows = HealthMetricType.allCases
                .filter { $0.category == category }
                .map { metric -> Row in
                    if let watchValue = watchValues[metric.rawValue] {
                        return Row(metric: metric, value: formatted(watchValue, metric))
                    }
                    return Row(metric: metric, value: healthKitValues[metric.rawValue] ?? "--")
                }
            return Section(category: category, rows: rows)
        }
    }

    private func formatted(_ value: Double, _ metric: HealthMetricType) -> String {
        String(format: "%.\(metric.fractionDigits)f", value)
    }

    /// Called when a fresh health snapshot arrives from the watch.
    private func applyWatchSnapshot(_ snapshot: WearableHealthSnapshot) {
        print("📱 [HealthMetrics] Applying watch snapshot (\(snapshot.values.count) metrics) to UI.")
        watchValues = snapshot.values
        rebuildRows()
    }

    func onAppear() {
        Task { await load() }
    }

    func refresh() {
        Task { await load() }
    }

    /// Guards against overlapping loads (SwiftUI `.onAppear` + the hosting
    /// controller's `viewWillAppear` both trigger a load, which otherwise races
    /// two HealthKit authorization sheets and fails to present either).
    private var isBusy = false

    private func load() async {
        guard repository.isHealthDataAvailable else {
            authorizationDenied = true
            return
        }
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }

        isLoading = true
        let authorized = await repository.requestAuthorization()
        print("🩺 [HealthMetrics] Authorization request completed (granted sheet: \(authorized)). Fetching \(HealthMetricType.allCases.count) metrics…")

        // Fetch every metric's current value concurrently.
        let repository = self.repository
        var values: [String: String] = [:]
        await withTaskGroup(of: (String, String).self) { group in
            for metric in HealthMetricType.allCases {
                group.addTask {
                    let value = await repository.currentDisplayValue(for: metric)
                    return (metric.rawValue, value)
                }
            }
            for await (key, value) in group {
                values[key] = value
            }
        }

        healthKitValues = values
        rebuildRows()
        isLoading = false

        print("🩺 [HealthMetrics] ===== Fetched values =====")
        for section in sections {
            print("  \(section.category.emoji) \(section.category.title)")
            for row in section.rows {
                print("    - \(row.metric.title): \(row.value) \(row.metric.unit)")
            }
        }
        print("🩺 [HealthMetrics] ==========================")
    }

    // MARK: - Navigation

    func openBack() {
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    func openMetric(_ metric: HealthMetricType) {
        guard metric.isHealthKitBacked else { return } // Stress has no source to chart.
        guard let nav = hostViewController?.navigationController else { return }
        let detail = HealthMetricDetailHostingController(metric: metric)
        nav.pushViewController(detail, animated: true)
    }
}
