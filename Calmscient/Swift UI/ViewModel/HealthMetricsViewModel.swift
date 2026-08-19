//
//  HealthMetricsViewModel.swift
//  Calmscient
//
//  Created by NFC Solutions on 11/08/26.
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class HealthMetricsViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    // MARK: - SwiftUI navigation
    //
    // Set by `HomeTabView` when this screen is shown inside the Home `NavigationStack`.
    // While nil, every call below falls through to the existing UIKit push/pop, which is
    // what the still-UIKit Discovery tab uses when it pushes into these screens.
    var onOpenRoute: ((HomeRoute) -> Void)?
    var onClose: (() -> Void)?
    var onCloseToRoot: (() -> Void)?

    @Published private(set) var screenTitle: String = ""
    @Published private(set) var sections: [HealthMetricSectionPresentation] = []
    @Published private(set) var isLoading = false
    @Published var authorizationDenied = false

    /// False until the first load has settled (or definitively failed).
    ///
    /// The screen used to render its "No health data yet" empty state on the very first
    /// frame — `sections` is empty and `isLoading` is still false at that point — then
    /// swap it for a spinner once `loadAll()` started, then swap again for the rows. On a
    /// first-ever open, where the HealthKit permission sheet sits in the middle of that
    /// sequence, those two unanimated swaps are the visible flick. Keeping one stable
    /// placeholder until this flips removes it.
    @Published private(set) var isInitialLoadFinished = false

    private var latestById: [String: HealthLatestValue] = [:]

    /// Re-entrancy guard for `loadAll()`. See the note there.
    private var isLoadingLatest = false

    // MARK: - Date range popup
    //
    // The calendar is a popup over this screen rather than a pushed screen, so the
    // results list is pushed *from here* — which is what makes back from the results
    // land on Health Metrics instead of on a calendar.
    @Published var isDateRangePickerPresented = false
    let dateRangePicker = HealthDateRangePickerViewModel()

    init() {
        dateRangePicker.onCancel = { [weak self] in
            self?.isDateRangePickerPresented = false
        }
        dateRangePicker.onSearch = { [weak self] startDate, endDate in
            guard let self else { return }
            self.isDateRangePickerPresented = false
            self.openRangeResults(startDate: startDate, endDate: endDate)
        }
    }

    /// Re-reads HealthKit every time the screen appears.
    ///
    /// This used to be guarded by `if sections.isEmpty`, which meant the first load was
    /// the only load: once rows existed they were never refreshed, so the numbers went
    /// stale as soon as you walked another hundred steps. HealthKit does not push updates
    /// to us (there is no observer query in the app), so appearing on screen is the right
    /// moment to pull. `loadAll()` guards itself against overlapping runs.
    func onHostWillAppear() {
        screenTitle = "Health Metrics".localized
        Task { await loadAll() }
    }

    /// First-open entry point: ask HealthKit for read access, then load.
    ///
    /// The request is held back until the push animation that brought this screen on
    /// screen has finished. HealthKit puts up its own modal sheet, and presenting that
    /// on top of an in-flight navigation transition is what makes the page jump. Waiting
    /// out the transition only shifts the prompt by the length of the push (~0.35s) —
    /// the prompt, the load and the error handling are otherwise unchanged.
    func requestAccessAndLoad() {
        // No transition in flight (already on screen, or pushed without animation):
        // behave exactly as before.
        guard let coordinator = hostViewController?.transitionCoordinator else {
            startAuthorizationAndLoad()
            return
        }

        let scheduled = coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            Task { @MainActor in self?.startAuthorizationAndLoad() }
        }

        // The coordinator refuses blocks for a non-animatable transition; without this
        // fallback the permission prompt would never be shown.
        if !scheduled { startAuthorizationAndLoad() }
    }

    private func startAuthorizationAndLoad() {
        Task {
            do {
                try await HealthKitManager.shared.requestAuthorization()
                await loadAll()
            } catch {
                authorizationDenied = true
                // Release the placeholder as well, otherwise the spinner would spin
                // forever on a device without Health data (e.g. iPad).
                isInitialLoadFinished = true
                hostViewController?.view.showToast(message: error.localizedDescription)
            }
        }
    }

    func loadAll() async {
        // `onHostWillAppear` now fires on every appearance, and pull-to-refresh can land
        // on top of it. Without this guard two passes would interleave their awaits and
        // the loser would overwrite `latestById` with its own older snapshot.
        guard !isLoadingLatest else { return }
        isLoadingLatest = true
        defer { isLoadingLatest = false }

        isLoading = true

        var cache: [String: HealthLatestValue] = [:]
        for metric in HealthMetric.all {
            cache[metric.id] = await HealthKitManager.shared.latestValue(for: metric)
        }
        latestById = cache

        rebuildSections()
        isLoading = false
        isInitialLoadFinished = true

        // Upload to the backend, but only if five hours have passed since the last
        // successful one — the service itself owns that decision, so this stays a plain
        // "here is fresh data" call that can fire on every load without spamming.
        // Values are handed over so the service doesn't re-read HealthKit for them.
        HealthSyncService.shared.syncIfDue(latest: cache)
    }

    /// Builds Favorites (if any) + category sections from the cache. No HealthKit access.
    private func rebuildSections() {
        let favIds = FavoriteMetricsStore.shared.favorites()
        let favSet = Set(favIds)

        var built: [HealthMetricSectionPresentation] = []

        // 1) Favorites on top, in pin order, skipping any stale ids (Step 4).
        let favRows: [HealthMetricRowPresentation] = favIds.compactMap { id in
            guard let metric = HealthMetric.metric(for: id) else { return nil }
            let latest = latestById[id] ?? HealthLatestValue(value: nil, displayText: "--")
            return HealthMetricRowPresentation(metric: metric, latest: latest, isFavorite: true)
        }
        if !favRows.isEmpty {
            built.append(HealthMetricSectionPresentation(
                id: "favorites", title: "Favorites".localized,
                isFavorites: true, rows: favRows))
        }

        // 2) Category sections; star reflects favorite state here too.
        for category in HealthMetricCategory.allCases {
            let metrics = HealthMetric.metrics(in: category)
            guard !metrics.isEmpty else { continue }

            let rows = metrics.map { metric in
                let latest = latestById[metric.id] ?? HealthLatestValue(value: nil, displayText: "--")
                return HealthMetricRowPresentation(
                    metric: metric, latest: latest,
                    isFavorite: favSet.contains(metric.id))
            }
            built.append(HealthMetricSectionPresentation(
                id: category.id, title: category.localizedTitle, rows: rows))
        }

        sections = built
    }
    
    func refresh() async { await loadAll() }

    func openBack() {
        if let onClose {
            onClose()
            return
        }
        hostViewController?.navigationController?.popViewController(animated: true)
    }
    
    func toggleFavorite(_ id: String) {
        let result = FavoriteMetricsStore.shared.toggle(id)
        if result.isFavorite && FavoriteMetricsStore.shared.count == FavoriteMetricsStore.shared.maxCount {
            hostViewController?.view.showToast(message: "Replaced your oldest favorite.".localized)
        }
        rebuildSections()
    }

    /// Optional (Step 7): clear all favorites.
    func resetFavorites() {
        FavoriteMetricsStore.shared.reset()
        rebuildSections()
    }

    // MARK: - Navigation to per-metric analytics

    func openDetail(forId id: String) {
        guard let metric = HealthMetric.metric(for: id) else { return }
        if let onOpenRoute {
            onOpenRoute(.healthMetricDetail(metric))
            return
        }
        guard let host = hostViewController else { return }
        HealthMetricDetailNavigation.push(from: host, metric: metric)
    }

    // MARK: - Navigation to the date range browser
    //
    // Opened from the calendar bar button. Same dual-navigation contract as
    // `openDetail(forId:)`: the route closure when the screen lives in the SwiftUI
    // Home stack, the UIKit push otherwise.

    func openDateRangePicker() {
        dateRangePicker.prepare()
        isDateRangePickerPresented = true
    }

    func dismissDateRangePicker() {
        isDateRangePickerPresented = false
    }

    private func openRangeResults(startDate: Date, endDate: Date) {
        if let onOpenRoute {
            onOpenRoute(.healthDataRange(startDate: startDate, endDate: endDate))
            return
        }
        guard let host = hostViewController else { return }
        HealthMetricsRangeNavigation.pushResults(from: host, startDate: startDate, endDate: endDate)
    }

}


#if DEBUG
@available(iOS 16.0, *)
extension HealthMetricsViewModel {

    /// Preview-only view model with dummy sections. Not compiled into release builds.
    static func previewModel() -> HealthMetricsViewModel {
        let vm = HealthMetricsViewModel()

        func row(_ id: String, _ text: String, fav: Bool = false) -> HealthMetricRowPresentation {
            let metric = HealthMetric.metric(for: id)!
            return HealthMetricRowPresentation(
                metric: metric,
                latest: HealthLatestValue(value: nil, displayText: text),
                isFavorite: fav)
        }

        vm.sections = [
            HealthMetricSectionPresentation(
                id: "favorites", title: "Favorites", isFavorites: true,
                rows: [row("heart_rate", "72 bpm", fav: true),
                       row("steps", "8,240 steps", fav: true)]),
            HealthMetricSectionPresentation(
                id: "Vitals", title: "Vitals",
                rows: [row("heart_rate", "72 bpm", fav: true),
                       row("spo2", "98 %"),
                       row("resting_hr", "61 bpm")]),
            HealthMetricSectionPresentation(
                id: "Activity", title: "Activity",
                rows: [row("steps", "8,240 steps", fav: true),
                       row("distance", "5.6 km"),
                       row("active_calories", "430 kcal")]),
        ]
        // Previews render the loaded state, not the placeholder.
        vm.isInitialLoadFinished = true
        return vm
    }
}
#endif
