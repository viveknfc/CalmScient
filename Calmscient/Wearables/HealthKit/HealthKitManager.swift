//
//  HealthKitManager.swift
//  Calmscient
//
//  Central HealthKit access for the iOS app: authorization, reading
//  heart rate / HRV / sleep / mindful minutes, and writing mindful sessions.
//
//  11 August 2026
//

import Foundation
import HealthKit

/// A lightweight snapshot of the health metrics CalmScient cares about.
struct HealthSnapshot {
    var latestHeartRate: Double?        // beats per minute
    var latestHRV: Double?              // milliseconds (SDNN)
    var sleepHoursLastNight: Double?    // hours asleep
    var mindfulMinutesToday: Double?    // minutes
}

@available(iOS 16.0, *)
final class HealthKitManager {

    static let shared = HealthKitManager()

    let store = HKHealthStore()

    private init() {}

    // MARK: - Types

    private var heartRateType: HKQuantityType { HKQuantityType(.heartRate) }
    private var hrvType: HKQuantityType { HKQuantityType(.heartRateVariabilitySDNN) }
    private var mindfulType: HKCategoryType { HKCategoryType(.mindfulSession) }
    private var sleepType: HKCategoryType { HKCategoryType(.sleepAnalysis) }

    /// Types we read.
    private var readTypes: Set<HKObjectType> {
        [heartRateType, hrvType, mindfulType, sleepType]
    }

    /// Types we write.
    private var writeTypes: Set<HKSampleType> {
        [mindfulType]
    }

    // MARK: - Availability & Authorization

    var isHealthDataAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    /// Requests read/write authorization. Note HealthKit never reveals whether
    /// the user granted *read* access, so a `true` result only means the sheet
    /// completed without error.
    func requestAuthorization() async -> Bool {
        guard isHealthDataAvailable else { return false }
        do {
            try await store.requestAuthorization(toShare: writeTypes, read: readTypes)
            return true
        } catch {
            print("HealthKit authorization failed: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Reads

    /// Most recent heart rate sample (bpm).
    func latestHeartRate() async -> Double? {
        await latestQuantity(heartRateType, unit: HKUnit.count().unitDivided(by: .minute()))
    }

    /// Most recent HRV SDNN sample (ms).
    func latestHRV() async -> Double? {
        await latestQuantity(hrvType, unit: HKUnit.secondUnit(with: .milli))
    }

    /// Total mindful minutes logged today.
    func mindfulMinutesToday() async -> Double? {
        let start = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date())
        let samples = await categorySamples(mindfulType, predicate: predicate)
        guard !samples.isEmpty else { return nil }
        let seconds = samples.reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
        return seconds / 60.0
    }

    /// Hours asleep for the most recent night.
    func sleepHoursLastNight() async -> Double? {
        let end = Date()
        let start = Calendar.current.date(byAdding: .hour, value: -24, to: end) ?? end
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
        let samples = await categorySamples(sleepType, predicate: predicate)
        let asleepValues: Set<Int> = [
            HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
            HKCategoryValueSleepAnalysis.asleepCore.rawValue,
            HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
            HKCategoryValueSleepAnalysis.asleepREM.rawValue
        ]
        let seconds = samples
            .filter { asleepValues.contains($0.value) }
            .reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
        return seconds > 0 ? seconds / 3600.0 : nil
    }

    /// Convenience: fetch everything the dashboard needs in one call.
    func loadSnapshot() async -> HealthSnapshot {
        async let hr = latestHeartRate()
        async let hrv = latestHRV()
        async let sleep = sleepHoursLastNight()
        async let mindful = mindfulMinutesToday()
        return await HealthSnapshot(
            latestHeartRate: hr,
            latestHRV: hrv,
            sleepHoursLastNight: sleep,
            mindfulMinutesToday: mindful
        )
    }

    // MARK: - Writes

    /// Logs a completed mindfulness/breathing session as a mindful-minutes sample.
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
            print("Failed to save mindful session: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Private query helpers

    private func latestQuantity(_ type: HKQuantityType, unit: HKUnit) async -> Double? {
        await withCheckedContinuation { continuation in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(
                sampleType: type,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                let value = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            store.execute(query)
        }
    }

    private func categorySamples(_ type: HKCategoryType, predicate: NSPredicate) async -> [HKCategorySample] {
        await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, _ in
                continuation.resume(returning: (samples as? [HKCategorySample]) ?? [])
            }
            store.execute(query)
        }
    }
}
