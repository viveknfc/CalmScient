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

    /// Ensures the HealthKit permission sheet is requested only once per screen.
    private var didRequestAuthorization = false

    /// The canonical cross-platform day fetched from the backend (fed by the
    /// paired device through the shared Android/Health Connect schema). This is
    /// the ONLY source for the dashboard: a metric shows a value only when the
    /// API carries it, otherwise the row is empty ("--"). Local HealthKit samples
    /// are never shown here.
    private var unifiedDay: WearableHealthDay?

    init() {
        rebuildRows()
    }

    /// Applies a canonical-schema day and rebuilds the rows from it.
    func apply(unifiedDay day: WearableHealthDay) {
        unifiedDay = day
        rebuildRows()
    }

    /// Rebuilds the section/row list purely from the server day. A metric with no
    /// value in the API response renders as "--".
    private func rebuildRows() {
        sections = HealthCategory.allCases.map { category in
            let rows = HealthMetricType.allCases
                .filter { $0.category == category }
                .map { metric in
                    Row(metric: metric, value: unifiedDay?.displayString(for: metric) ?? "--")
                }
            return Section(category: category, rows: rows)
        }
    }

    func onAppear() {
        // Kick the HealthKit permission sheet off immediately so it appears on
        // the FIRST entry to Health Metrics — not gated behind the (slower)
        // server fetch. HealthKit only presents the sheet once; later calls are
        // no-ops. The detail trend charts rely on this grant.
        Task { await requestAuthorizationIfNeeded() }
        Task { await load() }
    }

    func refresh() {
        Task { await requestAuthorizationIfNeeded() }
        Task { await load() }
    }

    /// Requests HealthKit read authorization once, presenting the system sheet
    /// promptly. Safe to call repeatedly.
    private func requestAuthorizationIfNeeded() async {
        guard !didRequestAuthorization, repository.isHealthDataAvailable else { return }
        didRequestAuthorization = true
        let granted = await repository.requestAuthorization()
        print("🩺 [HealthMetrics] HealthKit authorization requested on entry (sheet shown: \(granted)).")
    }

    /// Guards against overlapping loads (SwiftUI `.onAppear` + the hosting
    /// controller's `viewWillAppear` both trigger a load, which otherwise races
    /// two HealthKit authorization sheets and fails to present either).
    private var isBusy = false

    private func load() async {
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }

        isLoading = true
        // The dashboard is driven ONLY by the wearable API (server), which is fed
        // by the paired device via the cross-platform schema. If the API has no
        // data for this patient/date, every row stays empty ("--") — we never
        // fall back to the phone's local HealthKit samples.
        await loadServerDay()
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

    /// The date whose wearable data is shown. Defaults to today (current date);
    /// the backend is queried for this date and its values override local reads.
    var selectedDate: Date = Date()

    /// Fetches the canonical day from the backend for the **logged-in patient**
    /// and the **selected date** (today by default). When the API returns data,
    /// the rows show it; when it returns null/empty, the rows are cleared to "--".
    /// Silent on failure (no login, no network) — rows simply stay empty.
    private func loadServerDay() async {
        guard let patientId = ApplicationSharedInfo.shared.loginResponse?.patientID else {
            print("📥 [HealthMetrics] Skipping server fetch — no logged-in patient.")
            unifiedDay = nil
            rebuildRows()
            return
        }
        let date = selectedDate
        do {
            let day = try await WearableHealthService.fetch(patientId: patientId, date: date)
            if let day, !day.isEmpty {
                unifiedDay = day
                print("📥 [HealthMetrics] Applied server day (device: \(day.sourceDevice ?? "—"), date: \(day.date ?? "—")). Values come from the API response.")
            } else {
                unifiedDay = nil
                print("📥 [HealthMetrics] API returned no wearable data for patient \(patientId) on \(WearableHealthDay.dayFormatter.string(from: date)); rows left empty.")
            }
            rebuildRows()
        } catch {
            unifiedDay = nil
            rebuildRows()
            print("⚠️ [HealthMetrics] Wearable fetch failed: \(error.localizedDescription); rows left empty.")
        }
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
