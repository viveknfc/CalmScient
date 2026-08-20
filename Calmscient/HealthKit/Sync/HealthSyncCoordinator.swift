//
//  HealthSyncCoordinator.swift
//  Calmscient
//
//  Created by NFC Solutions on 19/08/26.
//

import Foundation
import BackgroundTasks
import HealthKit

/// Single owner of the health-sync lifecycle: the one entry point every trigger funnels through,
/// and the teardown that stops them all.
final class HealthSyncCoordinator {

    static let shared = HealthSyncCoordinator()
    private init() {}

    /// Must match `BGTaskSchedulerPermittedIdentifiers` in Info.plist **exactly**. A mismatch is a
    /// launch-time exception, not a warning — so this constant is the single source and
    /// registration/submission should both read it from here.
    static let refreshTaskIdentifier = "calmscientllc.com.healthsync.refresh"

    /// Where a sync attempt came from. Recorded so the diagnostic log can tell "iOS never woke us"
    /// apart from "we woke and the upload failed" — the two look identical from the backend.
    enum Trigger: String {
        case login              // immediately after a successful sign-in
        case foreground         // Health Metrics screen appeared
        case backgroundRefresh  // BGAppRefreshTask
        case healthKitObserver  // HKObserverQuery background delivery
        case silentPush         // remote notification with content-available
    }

    enum ShutdownReason: String {
        case sessionCleared     // logged out, or Remember Me turned off
    }

    // MARK: - Single-flight guard
    //
    // Not a theoretical race. Four HealthKit types are observed, and when a Watch syncs it writes
    // steps, heart rate and active energy within the same moment — so iOS can deliver several
    // observer callbacks in the same second, with a BGTask or a silent push possibly on top.
    //
    // Overlapping runs would duplicate the upload, which is merely wasteful. The real hazard is
    // two of them refreshing the token at once: Keycloak rotates the refresh token on use, so the
    // second request presents one the server has already retired. Depending on the realm's reuse
    // policy that either fails the call or is treated as a replayed token and kills the whole
    // session — an intermittent, unreproducible logout.
    //
    // A second caller returns immediately rather than queueing: it would upload the same slot's
    // data anyway, so bailing is both correct and cheaper.

    private let stateLock = NSLock()
    private var isSyncing = false

    private func beginSyncIfIdle() -> Bool {
        stateLock.lock()
        defer { stateLock.unlock() }
        guard !isSyncing else { return false }
        isSyncing = true
        return true
    }

    private func endSync() {
        stateLock.lock()
        isSyncing = false
        stateLock.unlock()
    }

    // MARK: - Entry points

    /// Fire-and-forget entry point, for callers that are not async — the login hook and, later,
    /// the Health Metrics screen.
    func syncNow(trigger: Trigger) {
        Task { await sync(trigger: trigger) }
    }

    /// Called straight after a successful login.
    ///
    /// This is the only upload a user who declined "Remember Me" will ever get without opening the
    /// Health Metrics screen, since there is no persisted session for a background wake-up to
    /// authenticate with. For everyone else it seeds a first row immediately instead of waiting on
    /// iOS to grant a background wake, which can take hours on a fresh install.
    func onLoginCompleted() {
        // At launch there was no persisted session to arm the background triggers with. There is
        // now, so this is the point they can start.
        startBackgroundTriggers()
        syncNow(trigger: .login)
    }

    /// The awaitable form. Background handlers need this so they can report real completion to
    /// iOS rather than finishing while the upload is still in flight.
    ///
    /// Returns whether a row actually reached the backend. "Skipped because this slot was already
    /// sent" is not a failure — from the scheduler's point of view there was nothing to do — so it
    /// returns `true`.
    @discardableResult
    func sync(trigger: Trigger) async -> Bool {

        guard beginSyncIfIdle() else {
            log(trigger: trigger, slotKey: nil, outcome: "skipped — sync already running")
            return true
        }
        defer { endSync() }

        // 1. Credentials, from the resolver that suits this trigger.
        guard let credentials = resolveCredentials(for: trigger) else {
            log(trigger: trigger, slotKey: nil, outcome: "skipped — no usable session")
            return false
        }

        // 2. Slot check. A login deliberately bypasses it and posts its own row.
        let slotStore = HealthSyncSlotStore.shared
        let slotStart = slotStore.currentSlotStart()
        let bypassesSlotCheck = (trigger == .login) && HealthSyncConfiguration.loginSyncBypassesSlotCheck

        if !bypassesSlotCheck {
            guard let slotStart = slotStart else {
                // Only reachable when the configured grid is empty, which means sync is off.
                log(trigger: trigger, slotKey: nil, outcome: "skipped — no slot grid configured")
                return true
            }
            guard !slotStore.hasSent(slotStart: slotStart) else {
                log(trigger: trigger, slotKey: HealthSyncSlotStore.slotKey(for: slotStart),
                    outcome: "skipped — slot already sent")
                return true
            }
        }

        // 3. A scheduled upload is stamped with its slot boundary, so a retry produces a
        //    byte-identical timestamp the backend can dedupe on. A login upload is stamped with
        //    the actual moment, so it can never collide with a slot row.
        let uploadDate = bypassesSlotCheck ? Date() : (slotStart ?? Date())
        let uploadKey = HealthSyncSlotStore.slotKey(for: uploadDate)

        // 4. A token that is actually valid right now.
        guard let accessToken = await validAccessToken(for: trigger, holding: credentials) else {
            log(trigger: trigger, slotKey: uploadKey, outcome: "failed — no valid access token")
            return false
        }

        // 5. Read HealthKit.
        let payload = await HealthSyncSnapshotBuilder.makeRequest(
            patientId: credentials.patientId,
            timestamp: uploadDate
        )

        // 5b. Nothing to say. Not a failure, and deliberately without marking the slot: if data
        //     turns up later in the same slot, the next wake-up will send it.
        guard !payload.containsNoReadings else {
            log(trigger: trigger, slotKey: uploadKey, outcome: "skipped — no health data available")
            return true
        }

        // 6. Upload. A 401 here means the token expired between the check above and the request —
        //    a narrow window, but cheaper to retry once than to abandon the slot for six hours.
        var result = await APIService.postWearableData(payload, accessToken: accessToken)

        if case .unauthorized = result {
            if await TokenManager.shared.refreshAccessTokenHeadless(),
               let refreshedToken = resolveCredentials(for: trigger)?.accessToken {
                result = await APIService.postWearableData(payload, accessToken: refreshedToken)
            }
        }

        // 7. Record the outcome. The slot is marked only on success, which is what gives
        //    retry-within-slot and drop-once-the-slot-passes without any queue.
        switch result {
        case .success:
            if !bypassesSlotCheck, let slotStart = slotStart {
                slotStore.markSent(slotStart: slotStart)
            }
            log(trigger: trigger, slotKey: uploadKey, outcome: "success")
            return true

        case .unauthorized:
            log(trigger: trigger, slotKey: uploadKey, outcome: "failed — unauthorized after refresh")
            return false

        case .failure(let message):
            log(trigger: trigger, slotKey: uploadKey, outcome: "failed — \(message)")
            return false
        }
    }

    // MARK: - Background triggers

    private var hasStartedBackgroundTriggers = false

    /// Registers the `BGAppRefreshTask` handler.
    ///
    /// Must be called from `didFinishLaunching` **before it returns**. Registering later throws,
    /// and the identifier has to match `BGTaskSchedulerPermittedIdentifiers` in Info.plist exactly
    /// — hence both reading it from `refreshTaskIdentifier`.
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.refreshTaskIdentifier,
                                        using: nil) { [weak self] task in
            self?.handleBackgroundRefresh(task)
        }
    }

    /// Starts HealthKit background delivery and queues the first refresh.
    ///
    /// Called at launch and again after login, because at launch there may be no persisted session
    /// yet. Idempotent — the second call does nothing.
    func startBackgroundTriggers() {
        stateLock.lock()
        let alreadyStarted = hasStartedBackgroundTriggers
        if !alreadyStarted { hasStartedBackgroundTriggers = true }
        stateLock.unlock()

        guard !alreadyStarted else { return }

        // No persisted session means no background wake-up could authenticate anything, so there
        // is nothing to arm yet. Login calls back in once there is.
        guard HealthSyncCredentials.current() != nil else {
            stateLock.lock()
            hasStartedBackgroundTriggers = false
            stateLock.unlock()
            return
        }

        HealthKitManager.shared.startObserverQueries(for: HealthSyncConfiguration.observedObjectTypes) { [weak self] completion in
            Task {
                await self?.sync(trigger: .healthKitObserver)
                // Must run on every path. iOS stops delivering to an app that does not acknowledge.
                completion()
            }
        }

        scheduleNextBackgroundRefresh()
    }

    /// Re-arms the triggers after HealthKit access has just been granted.
    ///
    /// Needed because `startBackgroundTriggers()` runs at launch, which on a fresh install is
    /// before the user has authorised anything — so `enableBackgroundDelivery` fails and the
    /// "already started" flag then blocks any retry. Without this the observer path stays dead
    /// until the next cold launch, which is precisely the day you would be testing it.
    ///
    /// Safe to call repeatedly: `startObserverQueries` stops the previous set first.
    func restartBackgroundTriggers() {
        stateLock.lock()
        hasStartedBackgroundTriggers = false
        stateLock.unlock()

        startBackgroundTriggers()
    }

    /// `BGAppRefreshTaskRequest` is one-shot, so every run has to queue its successor.
    ///
    /// `earliestBeginDate` is two hours rather than the six-hour slot gap because iOS treats it as
    /// "not before", never "at", and reliably runs late — asking early widens the window in which
    /// a slot can still be caught.
    func scheduleNextBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: Self.refreshTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: HealthSyncConfiguration.backgroundRefreshEarliestInterval)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            // Throws when background refresh is switched off for the app, or the task is not
            // permitted. Not recoverable here, and not fatal — the other triggers still work.
            print("HealthSync: could not schedule background refresh — \(error.localizedDescription)")
        }
    }

    private func handleBackgroundRefresh(_ task: BGTask) {
        // Queue the successor first, before any work that might not finish.
        scheduleNextBackgroundRefresh()

        // The work finishing and the expiration handler firing can both reach `setTaskCompleted`,
        // and calling it twice is a crash rather than a warning.
        let completionLock = NSLock()
        var hasCompleted = false
        let complete: (Bool) -> Void = { success in
            completionLock.lock()
            defer { completionLock.unlock() }
            guard !hasCompleted else { return }
            hasCompleted = true
            task.setTaskCompleted(success: success)
        }

        // Assigned *before* the work starts. iOS can withdraw the budget immediately, and with no
        // handler in place at that moment the process is killed outright instead of finishing
        // cleanly — which deprioritises every future refresh.
        var work: Task<Void, Never>?
        task.expirationHandler = {
            work?.cancel()
            complete(false)
        }

        work = Task {
            let didSend = await sync(trigger: .backgroundRefresh)
            complete(didSend)
        }
    }

    /// Entry point for a silent push — the only trigger the backend controls.
    @discardableResult
    func handleSilentPush() async -> Bool {
        await sync(trigger: .silentPush)
    }

    // MARK: - Credentials and token

    /// A user-present sync may use the in-memory session; an unattended one may only use a session
    /// the user agreed to persist. See `HealthSyncCredentials`.
    private func resolveCredentials(for trigger: Trigger) -> HealthSyncCredentials? {
        switch trigger {
        case .login, .foreground:
            return HealthSyncCredentials.forForegroundSync()
        case .backgroundRefresh, .healthKitObserver, .silentPush:
            return HealthSyncCredentials.current()
        }
    }

    /// Refreshes first when the stored token has expired, then re-reads through **the same
    /// resolver** the caller used.
    ///
    /// That last part is the whole point. Reading the refreshed token from the background
    /// resolver would return nil for a user who declined "Remember Me" — even though they have a
    /// perfectly good token in memory, having just logged in — and their login upload, the only
    /// one they ever get, would silently do nothing.
    private func validAccessToken(for trigger: Trigger,
                                  holding credentials: HealthSyncCredentials) async -> String? {
        guard TokenManager.shared.isTokenExpired() else {
            return credentials.accessToken
        }
        guard await TokenManager.shared.refreshAccessTokenHeadless() else {
            return nil
        }
        return resolveCredentials(for: trigger)?.accessToken
    }

    // MARK: - Diagnostics

    private func log(trigger: Trigger, slotKey: String?, outcome: String) {
        print("HealthSync[\(trigger.rawValue)] slot=\(slotKey ?? "-") → \(outcome)")
        HealthSyncSlotStore.shared.recordAttempt(trigger: trigger.rawValue,
                                                 slotKey: slotKey,
                                                 outcome: outcome)
    }

    // MARK: - Teardown

    /// Stops every background trigger and releases what they were going to use.
    ///
    /// Called from `UserDefaultsHelper.clearLoginDetailsFromUserDefaults()`, which every logout
    /// path in the app already funnels through — so this cannot be forgotten at a new call site.
    /// Safe to call when nothing was ever registered, and safe off the main thread.
    func shutdown(reason: ShutdownReason) {
        print("HealthSync: shutting down (\(reason.rawValue))")

        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Self.refreshTaskIdentifier)

        // Stop the in-process queries as well. `disableAllBackgroundDelivery` below prevents future
        // wake-ups, but the queries already executed keep running until the app restarts.
        HealthKitManager.shared.stopObserverQueries()

        // Background delivery survives app termination and re-launch, so it has to be turned off
        // explicitly — dropping the observer query is not enough. A local store instance is fine
        // for a disable-only call and keeps this independent of `HealthKitManager`.
        if HKHealthStore.isHealthDataAvailable() {
            HKHealthStore().disableAllBackgroundDelivery { _, error in
                if let error = error {
                    print("HealthSync: disableAllBackgroundDelivery failed: \(error.localizedDescription)")
                }
            }
        }

        stateLock.lock()
        hasStartedBackgroundTriggers = false
        stateLock.unlock()

        // Slot state belongs to the session that produced it. If one patient logs out and another
        // logs in during the same slot, a stale "already sent" mark would swallow the new
        // patient's first upload.
        HealthSyncSlotStore.shared.reset()
    }
}
