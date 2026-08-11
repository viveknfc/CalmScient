//
//  WatchHealthKitManager.swift
//  CalmscientWatch Watch App
//
//  Minimal HealthKit access on the watch: authorization plus writing a
//  completed breathing/mindfulness session as mindful minutes.
//
//  11 August 2026
//

import Foundation
import HealthKit

final class WatchHealthKitManager {

    static let shared = WatchHealthKitManager()

    private let store = HKHealthStore()
    private let calendar = Calendar.current
    private var mindfulType: HKCategoryType { HKCategoryType(.mindfulSession) }

    private init() {}

    var isHealthDataAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    /// Quantity metrics the watch reads and forwards to the phone.
    /// Tuple: (HealthMetricType.rawValue used as the key, HK identifier, unit, cumulative-today?).
    private var readMetrics: [(key: String, id: HKQuantityTypeIdentifier, unit: HKUnit, cumulative: Bool, scale: Double)] {
        [
            ("heartRate",            .heartRate,                 HKUnit.count().unitDivided(by: .minute()), false, 1),
            ("restingHeartRate",     .restingHeartRate,          HKUnit.count().unitDivided(by: .minute()), false, 1),
            ("heartRateVariability", .heartRateVariabilitySDNN,  HKUnit.secondUnit(with: .milli),           false, 1),
            ("respiratoryRate",      .respiratoryRate,           HKUnit.count().unitDivided(by: .minute()), false, 1),
            ("oxygenSaturation",     .oxygenSaturation,          HKUnit.percent(),                          false, 100),
            ("steps",                .stepCount,                 HKUnit.count(),                            true,  1),
            ("activeCalories",       .activeEnergyBurned,        HKUnit.kilocalorie(),                      true,  1),
            ("distance",             .distanceWalkingRunning,    HKUnit.meterUnit(with: .kilo),             true,  1),
            ("exerciseMinutes",      .appleExerciseTime,         HKUnit.minute(),                           true,  1),
        ]
    }

    private var readTypes: Set<HKObjectType> {
        Set(readMetrics.map { HKQuantityType($0.id) as HKObjectType }).union([mindfulType])
    }

    @discardableResult
    func requestAuthorization() async -> Bool {
        guard isHealthDataAvailable else { return false }
        do {
            try await store.requestAuthorization(toShare: [mindfulType], read: readTypes)
            return true
        } catch {
            print("Watch HealthKit authorization failed: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Snapshot

    /// Reads the watch's current health metrics into a snapshot to send to the phone.
    func captureSnapshot() async -> WearableHealthSnapshot {
        _ = await requestAuthorization()
        #if DEBUG
        await seedSampleDataIfSimulator()
        #endif
        var values: [String: Double] = [:]
        for metric in readMetrics {
            let raw: Double?
            if metric.cumulative {
                raw = await todaysSum(metric.id, unit: metric.unit)
            } else {
                raw = await mostRecent(metric.id, unit: metric.unit)
            }
            if let raw { values[metric.key] = raw * metric.scale }
        }
        // Wellness (mindful minutes today).
        if let mindful = await mindfulMinutesToday() { values["wellness"] = mindful }
        return WearableHealthSnapshot(values: values, capturedAt: Date().timeIntervalSince1970)
    }

    private func todaysSum(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double? {
        let start = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date())
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: HKQuantityType(id),
                                          quantitySamplePredicate: predicate,
                                          options: .cumulativeSum) { _, stats, _ in
                continuation.resume(returning: stats?.sumQuantity()?.doubleValue(for: unit))
            }
            store.execute(query)
        }
    }

    private func mostRecent(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double? {
        await withCheckedContinuation { continuation in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(sampleType: HKQuantityType(id), predicate: nil,
                                      limit: 1, sortDescriptors: [sort]) { _, samples, _ in
                continuation.resume(returning: (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: unit))
            }
            store.execute(query)
        }
    }

    private func mindfulMinutesToday() async -> Double? {
        let start = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date())
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: mindfulType, predicate: predicate,
                                      limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                let secs = (samples as? [HKCategorySample])?.reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) } ?? 0
                continuation.resume(returning: secs > 0 ? secs / 60.0 : nil)
            }
            store.execute(query)
        }
    }

    @discardableResult
    func saveMindfulSession(start: Date, end: Date) async -> Bool {
        guard isHealthDataAvailable, end > start else { return false }
        let sample = HKCategorySample(
            type: mindfulType,
            value: HKCategoryValue.notApplicable.rawValue,
            start: start,
            end: end
        )
        do {
            try await store.save(sample)
            return true
        } catch {
            print("Watch failed to save mindful session: \(error.localizedDescription)")
            return false
        }
    }

    #if DEBUG
    /// Simulator-only: writes a few sample readings into the watch's Health store
    /// so there's data to capture and send during a demo. No-op on real watches.
    private func seedSampleDataIfSimulator() async {
        #if targetEnvironment(simulator)
        // Only WRITABLE types (appleExerciseTime / restingHeartRate are read-only
        // and requesting share authorization for them raises an exception).
        let writableIds: [HKQuantityTypeIdentifier] = [
            .heartRate, .heartRateVariabilitySDNN, .respiratoryRate, .oxygenSaturation,
            .stepCount, .activeEnergyBurned, .distanceWalkingRunning
        ]
        var shareTypes: Set<HKSampleType> = Set(writableIds.map { HKQuantityType($0) as HKSampleType })
        shareTypes.insert(mindfulType)
        do {
            try await store.requestAuthorization(toShare: shareTypes, read: readTypes)
        } catch { return }

        let now = Date()
        let dayStart = calendar.startOfDay(for: now)
        var samples: [HKSample] = []

        func q(_ id: HKQuantityTypeIdentifier, _ unit: HKUnit, _ v: Double, start: Date, end: Date) {
            samples.append(HKQuantitySample(type: HKQuantityType(id),
                                            quantity: HKQuantity(unit: unit, doubleValue: v),
                                            start: start, end: end))
        }
        // Latest vitals.
        q(.heartRate, HKUnit.count().unitDivided(by: .minute()), 74, start: now, end: now)
        q(.heartRateVariabilitySDNN, HKUnit.secondUnit(with: .milli), 52, start: now, end: now)
        q(.respiratoryRate, HKUnit.count().unitDivided(by: .minute()), 15, start: now, end: now)
        q(.oxygenSaturation, HKUnit.percent(), 0.97, start: now, end: now)
        // Today's cumulative totals.
        let end = min(calendar.date(byAdding: .hour, value: 10, to: dayStart) ?? dayStart, now)
        q(.stepCount, HKUnit.count(), 6820, start: dayStart, end: end)
        q(.activeEnergyBurned, HKUnit.kilocalorie(), 380, start: dayStart, end: end)
        q(.distanceWalkingRunning, HKUnit.meterUnit(with: .kilo), 5.1, start: dayStart, end: end)

        do {
            try await store.save(samples)
            print("⌚ [Watch Health] Seeded \(samples.count) sample(s) into the watch Health store.")
        } catch {
            print("⌚ [Watch Health] Seed failed: \(error.localizedDescription)")
        }
        #endif
    }
    #endif
}
