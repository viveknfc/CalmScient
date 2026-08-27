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
    /// This no longer gates whether anything is on screen — `init()` builds the rows before
    /// any HealthKit read happens, so there is no empty frame to cover. It survives because
    /// it is still the honest answer to "have we finished reading at least once", which the
    /// error paths below rely on.
    @Published private(set) var isInitialLoadFinished = false

    private var latestById: [String: HealthLatestValue] = [:]

    /// Re-entrancy guard for `loadAll()`. See the note there.
    private var isLoadingLatest = false

    /// Set when a load is asked for while one is already running, so it can be run once at
    /// the end instead of being dropped. See `loadAll()`.
    private var hasPendingLoad = false

    /// Whether background delivery has been re-armed from this screen since launch.
    /// Per-process: the SwiftUI route rebuilds the view model on every push, so an instance
    /// flag would reset each visit and re-arm each visit, which is what this replaces.
    private static var hasRearmedBackgroundTriggersThisLaunch = false

    /// The last values read, kept for the lifetime of the process rather than the screen.
    ///
    /// `HealthMetricsRoute` holds the view model in a `@StateObject`, so popping back destroys
    /// it and the next push started from nothing: empty rows, then a full re-read of HealthKit
    /// before a single number could be drawn. On a phone with a real Health database that read
    /// is the visible pause. Seeding from here means a repeat visit renders the previous values
    /// on its first frame and the refresh happens behind them.
    ///
    /// Only ever read back for the patient it was recorded under. The values come from the
    /// device's own HealthKit store, so a second account on the same phone would read the same
    /// numbers anyway — but they are still somebody's health readings, and showing one patient
    /// a frame of another's is not a thing to leave to that reasoning.
    private static var cachedLatestById: [String: HealthLatestValue] = [:]
    private static var cachedPatientId: Int?

    private static var currentPatientId: Int? {
        ApplicationSharedInfo.shared.loginResponse?.patientID
    }

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

        // Draw the rows before anything is read. The catalog is static, so every section and
        // every row is known up front — only the *values* need HealthKit. Building them here
        // means the screen arrives with its real structure instead of an empty page: a repeat
        // visit shows the cached numbers immediately, a cold start shows the same rows with
        // the "--" that `rebuildSections()` already substitutes for a missing value, and they
        // fill in when the read lands.
        if let patientId = Self.currentPatientId, patientId == Self.cachedPatientId {
            latestById = Self.cachedLatestById
        }
        rebuildSections()
        isInitialLoadFinished = !latestById.isEmpty
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

    /// First-open entry point: load, and ask HealthKit for read access if it is still needed.
    ///
    /// These used to be one sequential step — request access, *then* read — with the whole
    /// thing held back until the push animation finished. Two problems came out of that:
    ///
    ///  - The read could not begin until the transition was over, so the screen was
    ///    guaranteed to be on display before the first query was even issued.
    ///  - `requestAuthorization()` ran on every single open. Asking HealthKit to run its
    ///    authorization flow means iOS spins up the Health app's own sheet, out of process,
    ///    and applies the modal card transform to us while it does — our whole UI scales
    ///    down over a black background. When the answer turns out to be "nothing to ask",
    ///    that sheet is torn down again without ever drawing, so all the user sees is the
    ///    page shrink and come back. That is the flick.
    ///
    /// They are separate concerns, so they are separated here. The read presents nothing and
    /// starts immediately, overlapping the push. The access request keeps the original
    /// wait-out-the-transition guard, because it is the part that can put a modal on screen —
    /// but it now only runs when it would actually achieve something.
    func requestAccessAndLoad() {
        Task { await loadAll() }

        // No transition in flight (already on screen, or pushed without animation):
        // behave exactly as before.
        guard let coordinator = hostViewController?.transitionCoordinator else {
            requestAuthorizationIfNeeded()
            return
        }

        let scheduled = coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            Task { @MainActor in self?.requestAuthorizationIfNeeded() }
        }

        // The coordinator refuses blocks for a non-animatable transition; without this
        // fallback the permission prompt would never be shown.
        if !scheduled { requestAuthorizationIfNeeded() }
    }

    private func requestAuthorizationIfNeeded() {
        // Everything below publishes, and this can be reached synchronously from the host's
        // `viewWillAppear` — which for the SwiftUI route is delivered *inside* a view-update
        // pass. Publishing from there is what produces "Publishing changes from within view
        // updates is not allowed", so all of it stays inside the `Task`, which resumes on a
        // later main-actor turn. `HomeHostBridge` hops its own appearance callbacks for the
        // same reason.
        Task {
            // No Health on this device at all. `needsAuthorizationRequest()` also returns
            // false here, so without this branch the "Health data is not available on this
            // device" toast that `requestAuthorization()` used to throw would silently stop
            // appearing.
            guard HealthKitManager.shared.isHealthDataAvailable else {
                authorizationDenied = true
                isInitialLoadFinished = true
                hostViewController?.view.showToast(
                    message: "Health data is not available on this device.".localized)
                return
            }

            // Re-arm background delivery once per launch, whether or not there is anything
            // left to ask.
            //
            // This used to happen on every visit, as a side effect of the unconditional
            // authorization request. Most of that was waste — `startObserverQueries` stops the
            // previous set before installing a new one, so each visit briefly left nothing
            // armed — but it did carry one real recovery path: arming at launch fails when
            // nothing was authorised yet, and someone who granted categories in Settings →
            // Health afterwards got picked up the next time they opened this screen. Doing it
            // once per launch keeps that and drops the churn.
            if !Self.hasRearmedBackgroundTriggersThisLaunch {
                Self.hasRearmedBackgroundTriggersThisLaunch = true
                HealthSyncCoordinator.shared.restartBackgroundTriggers()
            }

            // Would asking put anything on screen? `.shouldRequest` means at least one
            // requested type has never been answered by this user. This is a plain status
            // query — it is documented not to prompt, and `HealthAccessPrompt` already leans
            // on that — so on the overwhelmingly common path (everything already answered)
            // the authorization flow never runs and nothing is ever presented over us.
            //
            // Note this deliberately says nothing about whether access was *granted*: Apple
            // hides read authorization on purpose. Someone who refused is skipped here for
            // the same reason someone who accepted is — there is no second question to ask —
            // and `loadAll()` reads exactly as it did before, returning "--" for whatever is
            // being withheld.
            guard await HealthKitManager.shared.needsAuthorizationRequest() else { return }

            do {
                try await HealthKitManager.shared.requestAuthorization()

                // Access has only just changed, so re-arm again regardless of the once-per-launch
                // check above — that earlier call ran before the grant and could not have
                // succeeded. Same reason as in `HealthAccessPrompt`.
                HealthSyncCoordinator.shared.restartBackgroundTriggers()

                // The load that started alongside the push read the old permissions, so read
                // again now that they may have changed. If that first pass somehow has not
                // finished yet, `loadAll()` coalesces this request onto the end of it rather
                // than dropping it, so the post-grant values always reach the screen.
                await loadAll()
            } catch {
                authorizationDenied = true
                // Kept for the case this still matters: a device without Health data at all
                // (e.g. iPad) never completes a load, and this is what marks that as settled.
                isInitialLoadFinished = true
                hostViewController?.view.showToast(message: error.localizedDescription)
            }
        }
    }

    func loadAll() async {
        // `onHostWillAppear` fires on every appearance, and pull-to-refresh (or the re-read
        // that follows a just-granted permission) can land on top of it. Two passes must not
        // interleave their awaits — the loser would overwrite `latestById` with its own older
        // snapshot — so a request that arrives mid-pass is remembered and run once at the end
        // instead of being dropped. Dropping it was what could leave a first-ever grant showing
        // "--" until the screen was left and re-entered.
        guard !isLoadingLatest else {
            hasPendingLoad = true
            return
        }
        isLoadingLatest = true
        defer { isLoadingLatest = false }

        // Callers must be event-driven (an appearance callback, a pull-to-refresh, the
        // post-grant re-read). `readAllMetrics()` publishes `isLoading` and `sections`, so a
        // caller reached from a view body or an `onChange` of those would re-request on every
        // pass and this would never terminate.
        repeat {
            hasPendingLoad = false
            await readAllMetrics()
        } while hasPendingLoad
    }

    /// One pass over the catalog. Assumes the caller holds `isLoadingLatest`.
    private func readAllMetrics() async {
        isLoading = true

        // Concurrent, not sequential.
        //
        // This was `for metric in HealthMetric.all { cache[id] = await ... }`, which issued
        // 21 HealthKit queries strictly one after another — each one waiting for the previous
        // to come back from the Health daemon. The cost was therefore the *sum* of 21 round
        // trips, and since that cost scales with how much history is in the store, a phone
        // with a real Health database (years of samples, a paired Watch) spent most of a second
        // there while a Simulator with an empty store finished instantly. That difference is
        // the whole reason this looked fine in the simulator and slow on a real device.
        //
        // The queries are independent, so they all go out at once and the cost becomes the
        // slowest single query rather than the total. Results are collected out of the group
        // and only then assigned, so `latestById` is still replaced atomically by one complete
        // snapshot — exactly as the sequential version did.
        var snapshot: [String: HealthLatestValue] = [:]
        await withTaskGroup(of: (String, HealthLatestValue).self) { group in
            for metric in HealthMetric.all {
                group.addTask {
                    (metric.id, await HealthKitManager.shared.latestValue(for: metric))
                }
            }
            for await (id, value) in group {
                snapshot[id] = value
            }
        }

        latestById = snapshot
        Self.cachedLatestById = snapshot
        Self.cachedPatientId = Self.currentPatientId

        rebuildSections()
        isLoading = false
        isInitialLoadFinished = true

        // Opening this screen is a free chance to fill the current slot: HealthKit has just been
        // read anyway and the user is present. `syncNow` returns immediately when the slot has
        // already been sent, so repeated visits cost nothing.
        HealthSyncCoordinator.shared.syncNow(trigger: .foreground)
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
