//
//  HealthSyncSnapshotBuilder.swift
//  Calmscient
//
//  Created by NFC Solutions on 19/08/26.
//

import Foundation
import HealthKit
import UIKit

/// Turns the current HealthKit state into one `WearableDataUploadRequest`.
///
/// Reads run concurrently through `async let`, for the same reason `HealthMetricsViewModel` fans
/// its own reads out across a task group: twenty HealthKit round trips one after another add up,
/// and here there is a hard ceiling on the total — a background wake-up gets roughly thirty
/// seconds.
///
/// Anything HealthKit cannot answer becomes `""`. Never `"0"` — a clinician reading "weight 0 kg"
/// sees a measurement, not a gap.
enum HealthSyncSnapshotBuilder {

    /// Catalog ids this builder depends on. They must stay in step with `HealthMetric.all`;
    /// `rawValue(forCatalogId:)` asserts in debug builds if one stops resolving.
    private enum CatalogID {
        static let heartRate        = "heart_rate"
        static let restingHeartRate = "resting_hr"
        static let spo2             = "spo2"
        static let respiratoryRate  = "respiratory_rate"
        static let hrv              = "hrv"
        static let steps            = "steps"
        static let distance         = "distance"
        static let exerciseMinutes  = "exercise"
        static let weight           = "weight"
        static let height           = "height"
        static let bodyFat          = "body_fat"
        static let bloodGlucose     = "blood_glucose"
        static let sleep            = "sleep"
        static let hydration        = "hydration"
        static let wellness         = "wellness"
    }

    /// Builds the payload.
    ///
    /// `timestamp` is passed in rather than derived here so the caller decides what the row
    /// represents: a scheduled upload sends its slot boundary (identical on every retry, so the
    /// backend can dedupe), while a login upload sends the actual moment.
    static func makeRequest(patientId: Int, timestamp: Date) async -> WearableDataUploadRequest {

        // --- Vitals ---
        async let heartRateTask        = rawValue(forCatalogId: CatalogID.heartRate)
        async let restingHeartRateTask = rawValue(forCatalogId: CatalogID.restingHeartRate)
        async let spo2Task             = rawValue(forCatalogId: CatalogID.spo2)
        async let respiratoryRateTask  = rawValue(forCatalogId: CatalogID.respiratoryRate)
        async let hrvTask              = rawValue(forCatalogId: CatalogID.hrv)
        async let bloodPressureTask    = HealthKitManager.shared.latestBloodPressurePair()

        // --- Activity ---
        async let stepsTask            = rawValue(forCatalogId: CatalogID.steps)
        async let distanceTask         = rawValue(forCatalogId: CatalogID.distance)
        async let exerciseMinutesTask  = rawValue(forCatalogId: CatalogID.exerciseMinutes)
        async let energyTask           = HealthKitManager.shared.todayEnergySummary()
        async let workoutTypeTask      = HealthKitManager.shared.todayLatestWorkoutTypeName()

        // --- Body ---
        async let weightTask           = rawValue(forCatalogId: CatalogID.weight)
        async let heightTask           = rawValue(forCatalogId: CatalogID.height)
        async let bodyFatTask          = rawValue(forCatalogId: CatalogID.bodyFat)
        async let bloodGlucoseTask     = rawValue(forCatalogId: CatalogID.bloodGlucose)

        // --- Sleep / nutrition / wellness ---
        async let sleepTask            = rawValue(forCatalogId: CatalogID.sleep)
        async let hydrationTask        = rawValue(forCatalogId: CatalogID.hydration)
        async let wellnessTask         = rawValue(forCatalogId: CatalogID.wellness)

        // --- Provenance ---
        async let sourceNameTask       = HealthKitManager.shared.latestSampleSourceName()

        let bloodPressure = await bloodPressureTask
        let energy = await energyTask

        let vitals = WearableDataUploadRequest.Vitals(
            heartRate:         WearableValueFormatter.integer(await heartRateTask),
            // No HealthKit equivalent. The dashboard's "stress" row is a 100 − HRV placeholder
            // with no clinical basis, so it is deliberately not forwarded as if it were data.
            stressLevel:       "",
            restingHeartRate:  WearableValueFormatter.integer(await restingHeartRateTask),
            spo2:              WearableValueFormatter.integer(await spo2Task),
            respiratoryRate:   WearableValueFormatter.integer(await respiratoryRateTask),
            systolicPressure:  WearableValueFormatter.integer(bloodPressure.systolic),
            diastolicPressure: WearableValueFormatter.integer(bloodPressure.diastolic),
            hrv:               WearableValueFormatter.integer(await hrvTask)
        )

        let activity = WearableDataUploadRequest.Activity(
            steps:           WearableValueFormatter.integer(await stepsTask),
            distance:        WearableValueFormatter.oneDecimal(await distanceTask),
            activeCalories:  WearableValueFormatter.integer(energy.active),
            totalCalories:   WearableValueFormatter.integer(energy.total),
            exerciseMinutes: WearableValueFormatter.integer(await exerciseMinutesTask),
            exerciseType:    await workoutTypeTask ?? ""
        )

        let body = WearableDataUploadRequest.Body(
            weight:       WearableValueFormatter.oneDecimal(await weightTask),
            height:       WearableValueFormatter.integer(await heightTask),
            bodyFat:      WearableValueFormatter.oneDecimal(await bodyFatTask),
            bloodGlucose: WearableValueFormatter.integer(await bloodGlucoseTask),
            // Resting energy for today, which is the same basal figure the total above includes.
            bmr:          WearableValueFormatter.integer(energy.basal)
        )

        let sleep = WearableDataUploadRequest.Sleep(
            sleepHours: WearableValueFormatter.oneDecimal(await sleepTask)
        )

        let nutrition = WearableDataUploadRequest.Nutrition(
            hydration: WearableValueFormatter.oneDecimal(await hydrationTask)
        )

        let wellness = WearableDataUploadRequest.Wellness(
            wellnessMinutes: WearableValueFormatter.integer(await wellnessTask)
        )

        return WearableDataUploadRequest(
            patientId: patientId,
            // Same epoch-millisecond encoding the slot grid uses, applied to whatever instant the
            // caller chose.
            timestamp: HealthSyncSlotStore.slotKey(for: timestamp),
            sourceDevice: await resolveSourceDevice(reportedName: await sourceNameTask),
            vitals: vitals,
            activity: activity,
            body: body,
            sleep: sleep,
            nutrition: nutrition,
            wellness: wellness
        )
    }

    // MARK: - Helpers

    /// The raw number behind a dashboard metric.
    ///
    /// `latestValue(for:)` already returns exactly the figure the API wants — today's total for
    /// cumulative metrics, the newest reading for discrete ones — and its `value` is the
    /// unformatted `Double`. Reusing it keeps the uploaded number and the on-screen number from
    /// ever disagreeing.
    private static func rawValue(forCatalogId id: String) async -> Double? {
        guard let metric = HealthMetric.metric(for: id) else {
            // A silently empty field is a poor way to find out a catalog id was renamed.
            // Compiled out of release builds.
            assertionFailure("Unknown HealthMetric id '\(id)' — HealthSyncSnapshotBuilder is out of step with HealthMetric.all")
            return nil
        }
        return await HealthKitManager.shared.latestValue(for: metric).value
    }

    /// Falls back to the device model when no sample carries provenance — a brand-new install
    /// with no Watch, for instance. `UIDevice` is main-thread API, and this can be reached from a
    /// background wake-up, hence the hop.
    private static func resolveSourceDevice(reportedName: String?) async -> String {
        if let reportedName = reportedName, !reportedName.isEmpty {
            return reportedName
        }
        return await MainActor.run { UIDevice.current.model }
    }
}
