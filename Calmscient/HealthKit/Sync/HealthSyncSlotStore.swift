//
//  HealthSyncSlotStore.swift
//  Calmscient
//
//  Created by NFC Solutions on 19/08/26.
//

import Foundation

/// Answers the only two questions the sync scheduler needs: *which slot are we in?* and
/// *has it been sent?*
///
/// The whole retry policy falls out of those two facts and one stored string:
///
///   - A wake-up inside a slot that was already sent exits immediately, touching no network.
///   - A failed upload simply does not mark the slot, so the next wake-up inside the same slot
///     tries again.
///   - Once the slot rolls over, the unsent one is abandoned. No queue, no backfill — which is
///     exactly the agreed behaviour ("send the latest data at the slot; drop anything missed").
final class HealthSyncSlotStore {

    static let shared = HealthSyncSlotStore()
    private init() {}

    private let lastSentSlotKeyDefaultsKey = "HealthSync.lastSentSlotKey"
    private let attemptLogDefaultsKey = "HealthSync.attemptLog"

    /// Guards the read-modify-write of the attempt log. A background wake-up and a foreground
    /// sync can overlap, and `UserDefaults` being thread-safe per access does not make
    /// read-append-write atomic.
    private let logLock = NSLock()

    // MARK: - Slot arithmetic
    //
    // Kept static and free of stored state so it can be exercised directly from a test or a
    // playground: feed it a date and a grid, check the answer.

    /// The most recent slot boundary at or before `date`, in local time.
    ///
    /// Searches today's boundaries newest-first, then falls back to yesterday's — which is what
    /// covers the window between midnight and the first slot hour of the day when the grid does
    /// not start at 0.
    ///
    /// Returns nil only when the grid is empty, which the caller treats as "sync disabled".
    ///
    /// Boundaries are built by adding hours to the start of the day. On the two DST transition
    /// days a year that can put a boundary an hour off the nominal wall clock; that is accepted
    /// deliberately, because a sync cadence is not an appointment and the alternative
    /// (`date(bySettingHour:...)`, which returns nil for an hour that does not exist during the
    /// spring-forward gap) trades a harmless one-hour shift for a missing slot.
    static func slotStart(for date: Date,
                          slotHours: [Int] = HealthSyncConfiguration.slotHours,
                          calendar: Calendar = .current) -> Date? {

        let hours = HealthSyncConfiguration.sanitised(slotHours)
        guard !hours.isEmpty else { return nil }

        for dayOffset in [0, -1] {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: date) else { continue }
            let startOfDay = calendar.startOfDay(for: day)

            for hour in hours.reversed() {
                guard let boundary = calendar.date(byAdding: .hour, value: hour, to: startOfDay) else { continue }
                if boundary <= date { return boundary }
            }
        }

        return nil
    }

    /// The value the backend receives as `timestamp`: epoch **milliseconds**, as a string —
    /// e.g. `"1787116200000"`. Matches the agreed contract, and being derived from the slot
    /// boundary rather than the moment of sending it is identical on every retry, so the server
    /// can treat `(patientId, timestamp)` as a natural dedupe key.
    static func slotKey(for slotStart: Date) -> String {
        String(Int64((slotStart.timeIntervalSince1970 * 1000).rounded()))
    }

    // MARK: - Slot state

    func currentSlotStart(now: Date = Date()) -> Date? {
        Self.slotStart(for: now)
    }

    var lastSentSlotKey: String? {
        UserDefaults.standard.string(forKey: lastSentSlotKeyDefaultsKey)
    }

    func hasSent(slotStart: Date) -> Bool {
        lastSentSlotKey == Self.slotKey(for: slotStart)
    }

    func markSent(slotStart: Date) {
        UserDefaults.standard.set(Self.slotKey(for: slotStart), forKey: lastSentSlotKeyDefaultsKey)
    }

    /// Clears slot state and the diagnostic log.
    ///
    /// Called from `HealthSyncCoordinator.shutdown(reason:)`. Without it, a device where one
    /// patient logs out and another logs in during the same slot would skip the new patient's
    /// first upload, because the slot would still be marked as sent.
    func reset() {
        UserDefaults.standard.removeObject(forKey: lastSentSlotKeyDefaultsKey)
        logLock.lock()
        UserDefaults.standard.removeObject(forKey: attemptLogDefaultsKey)
        logLock.unlock()
    }

    // MARK: - Diagnostic log
    //
    // The only way to tell "iOS never woke us" apart from "we woke and the upload failed" once
    // this is running unattended. A debugger cannot be attached to a 3am wake-up.

    struct Attempt: Codable {
        let at: Date
        let trigger: String
        let slotKey: String?
        let outcome: String
    }

    func recordAttempt(trigger: String, slotKey: String?, outcome: String) {
        logLock.lock()
        defer { logLock.unlock() }

        var entries = decodeAttempts()
        entries.append(Attempt(at: Date(), trigger: trigger, slotKey: slotKey, outcome: outcome))

        if entries.count > HealthSyncConfiguration.attemptLogLimit {
            entries.removeFirst(entries.count - HealthSyncConfiguration.attemptLogLimit)
        }

        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: attemptLogDefaultsKey)
        }
    }

    func attempts() -> [Attempt] {
        logLock.lock()
        defer { logLock.unlock() }
        return decodeAttempts()
    }

    /// Caller must already hold `logLock`.
    private func decodeAttempts() -> [Attempt] {
        guard let data = UserDefaults.standard.data(forKey: attemptLogDefaultsKey),
              let entries = try? JSONDecoder().decode([Attempt].self, from: data) else {
            return []
        }
        return entries
    }
}
