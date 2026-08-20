//
//  HealthSyncConfiguration.swift
//  Calmscient
//
//  Created by NFC Solutions on 19/08/26.
//

import Foundation
import HealthKit

/// Every tunable of the health-sync cadence in one place.
///
/// The cadence is expressed as a set of **local clock hours**, not as an interval, and that is
/// deliberate. iOS gives no guaranteed timer, so "every 6 hours" cannot be scheduled — but "has
/// the 12:00 slot been sent yet?" can be answered on whatever irregular wake-up iOS grants.
/// Changing the cadence therefore means editing `defaultSlotHours` and nothing else.
enum HealthSyncConfiguration {

    // MARK: - Cadence

    /// Local hours at which a snapshot is due. Four slots a day, six hours apart.
    ///
    /// Offset from midnight on purpose. Cumulative fields — steps, distance, calories, hydration,
    /// exercise minutes — are read as "today so far", so a slot at 00:00 would report ~0 for all
    /// of them, and the last useful slot of the day would be 18:00, silently under-reporting every
    /// patient's day by the six hours after it. Ending the day at 23:00 instead captures 23 hours,
    /// which is close enough to a daily total to be usable clinically, and every row keeps the
    /// same clean "today so far" meaning.
    ///
    /// Any count works: `[8, 20]` for twice daily, `[0, 3, 6, 9, 12, 15, 18, 21]` for eight.
    /// The list is sanitised before use, so an out-of-range or duplicated entry cannot produce a
    /// broken grid.
    private static let defaultSlotHours: [Int] = [5, 11, 17, 23]

    /// The slot grid actually in force, after sanitising and any debug override.
    /// An empty result disables sync rather than crashing — see `HealthSyncSlotStore`.
    static var slotHours: [Int] {
        sanitised(rawSlotHours)
    }

    /// Drops anything outside 0...23, removes duplicates, and sorts ascending.
    static func sanitised(_ hours: [Int]) -> [Int] {
        Array(Set(hours.filter { (0...23).contains($0) })).sorted()
    }

    // MARK: - Networking

    /// How far ahead a `BGAppRefreshTask` is requested. Asked earlier than the 6-hour slot gap on
    /// purpose: iOS treats this as "not before", never "at", and reliably runs it late.
    static let backgroundRefreshEarliestInterval: TimeInterval = 2 * 60 * 60

    /// Matches the timeout every other call in `APIService` uses.
    static let requestTimeout: TimeInterval = 6

    // MARK: - Behaviour

    /// A successful login always uploads, even if the current slot was already sent.
    ///
    /// This is what covers users who declined "Remember Me": with no session on disk, no
    /// background wake-up can ever authenticate for them, so login is their only upload.
    static let loginSyncBypassesSlotCheck = true

    /// How many attempts the rolling diagnostic log keeps.
    static let attemptLogLimit = 30

    // MARK: - Background delivery

    /// The HealthKit types whose new samples are allowed to wake the app.
    ///
    /// Deliberately short. Each observed type is an independent wake-up source, and battery cost
    /// scales with the *number of wake-ups*, not with how much is uploaded — so observing all 22
    /// fields would multiply the cost without producing a single extra upload. These four change
    /// often enough to be a useful "something happened" signal, and one wake-up reads everything
    /// regardless of which type triggered it.
    static var observedObjectTypes: [HKObjectType] {
        var types: [HKObjectType] = []

        let quantityIdentifiers: [HKQuantityTypeIdentifier] = [
            .stepCount,
            .heartRate,
            .activeEnergyBurned
        ]
        for identifier in quantityIdentifiers {
            if let type = HKObjectType.quantityType(forIdentifier: identifier) {
                types.append(type)
            }
        }

        // Sleep is a category type, not a quantity type, so it cannot live in the list above.
        if let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            types.append(sleep)
        }

        return types
    }

    // MARK: - Debug override

    /// Lets QA shorten the grid on a test build — e.g. every hour — without a rebuild:
    /// `UserDefaults.standard.set(Array(0...23), forKey: "HealthSync.debugSlotHours")`
    ///
    /// Compiled out of release builds so a stray value can never ship.
    static let debugSlotHoursOverrideKey = "HealthSync.debugSlotHours"

    private static var rawSlotHours: [Int] {
        #if DEBUG
        if let override = UserDefaults.standard.array(forKey: debugSlotHoursOverrideKey) as? [Int],
           !override.isEmpty {
            return override
        }
        #endif
        return defaultSlotHours
    }
}
