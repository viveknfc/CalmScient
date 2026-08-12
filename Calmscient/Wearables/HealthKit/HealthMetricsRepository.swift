//
//  HealthMetricsRepository.swift
//  Calmscient
//
//  Reads current values and Daily/Weekly/Monthly/Yearly trends for each
//  HealthMetricType from HealthKit.
//
//  11 August 2026
//

import Foundation
import HealthKit

@available(iOS 16.0, *)
final class HealthMetricsRepository: @unchecked Sendable {

    static let shared = HealthMetricsRepository()

    private let store = HealthKitManager.shared.store
    private let calendar = Calendar.current

    /// Compact formatter used only for console logging of fetched samples.
    private static let logDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, HH:mm"
        return f
    }()

    private init() {}

    var isHealthDataAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    // MARK: - Authorization

    /// Read types covering every HealthKit-backed metric in the catalog.
    private var readTypes: Set<HKObjectType> {
        var types = Set<HKObjectType>()
        for metric in HealthMetricType.allCases {
            if let id = metric.quantityTypeIdentifier {
                types.insert(HKQuantityType(id))
            }
        }
        types.insert(HKQuantityType(.bloodPressureSystolic))
        types.insert(HKQuantityType(.bloodPressureDiastolic))
        types.insert(HKQuantityType(.basalEnergyBurned))   // for total Calories
        types.insert(HKCategoryType(.sleepAnalysis))
        types.insert(HKCategoryType(.mindfulSession))
        types.insert(HKObjectType.workoutType())           // for exerciseType
        return types
    }

    @discardableResult
    func requestAuthorization() async -> Bool {
        guard isHealthDataAvailable else { return false }
        do {
            try await store.requestAuthorization(toShare: [HKCategoryType(.mindfulSession)], read: readTypes)
            return true
        } catch {
            print("HealthMetrics authorization failed: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Current value (dashboard)

    /// A formatted current value for the dashboard row, e.g. "72", "120/80", "--".
    func currentDisplayValue(for metric: HealthMetricType) async -> String {
        let value = await computeCurrentDisplayValue(for: metric)
        print("🩺 [HealthMetrics] \(metric.title): \(value) \(metric.unit)")
        return value
    }

    private func computeCurrentDisplayValue(for metric: HealthMetricType) async -> String {
        guard isHealthDataAvailable else { return "--" }

        switch metric {
        case .stress:
            return "--" // No HealthKit source.
        case .bloodPressure:
            if let bp = await latestBloodPressure() {
                return "\(Int(bp.systolic))/\(Int(bp.diastolic))"
            }
            return "--"
        case .calories:
            let active = await todaysSum(.activeEnergyBurned, unit: .kilocalorie())
            let basal = await todaysSum(.basalEnergyBurned, unit: .kilocalorie())
            let total = (active ?? 0) + (basal ?? 0)
            return total > 0 ? format(total, digits: 0) : "--"
        default:
            if let value = await currentRawValue(for: metric) {
                return format(value, digits: metric.fractionDigits)
            }
            return "--"
        }
    }

    /// The numeric current value (already scaled for display), or nil.
    private func currentRawValue(for metric: HealthMetricType) async -> Double? {
        switch metric.aggregation {
        case .cumulativeSum:
            guard let id = metric.quantityTypeIdentifier else { return nil }
            return await todaysSum(id, unit: metric.hkUnit)
        case .discreteAverage, .mostRecent:
            guard let id = metric.quantityTypeIdentifier else { return nil }
            if let raw = await mostRecentQuantity(id, unit: metric.hkUnit) {
                return metric.displayValue(fromHK: raw)
            }
            return nil
        case .categoryDuration:
            switch metric {
            case .sleep:    return await sleepHoursLastNight()
            case .wellness: return await mindfulMinutesToday()
            default:        return nil
            }
        }
    }

    // MARK: - Unified cross-platform payload (Android-compatible schema)

    /// Numeric current value for a metric (already display-scaled), or nil.
    /// Public so the unified serializer can build a payload that shares the exact
    /// keys the Android (Health Connect) client posts.
    func currentValue(for metric: HealthMetricType) async -> Double? {
        switch metric {
        case .stress:
            return nil // No HealthKit source (Android's `stressLevel`).
        case .bloodPressure:
            return (await latestBloodPressure())?.systolic
        case .calories:
            let active = await todaysSum(.activeEnergyBurned, unit: .kilocalorie())
            let basal = await todaysSum(.basalEnergyBurned, unit: .kilocalorie())
            let total = (active ?? 0) + (basal ?? 0)
            return total > 0 ? total : nil
        default:
            return await currentRawValue(for: metric)
        }
    }

    /// Latest workout's activity type, mapped to the shared `exerciseType`
    /// vocabulary (Walking, Running, …). Nil when there's no recent workout.
    func latestExerciseType() async -> String? {
        await withCheckedContinuation { continuation in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(sampleType: HKObjectType.workoutType(),
                                      predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
                let name = (samples?.first as? HKWorkout).map { Self.exerciseTypeName(for: $0.workoutActivityType) }
                continuation.resume(returning: name)
            }
            store.execute(query)
        }
    }

    /// Builds one day's snapshot in the canonical cross-platform schema from live
    /// HealthKit reads. The result serializes to the same JSON keys the Android
    /// client and backend use, so a single parser/serializer covers both.
    func buildUnifiedDay(patientId: Int,
                         date: Date = Date(),
                         sourceDevice: String = "iPhone") async -> WearableHealthDay {
        var values: [HealthMetricType: Double] = [:]
        await withTaskGroup(of: (HealthMetricType, Double?).self) { group in
            for metric in HealthMetricType.allCases where metric != .bloodPressure {
                group.addTask { (metric, await self.currentValue(for: metric)) }
            }
            for await (metric, value) in group {
                if let value { values[metric] = value }
            }
        }
        async let bloodPressure = latestBloodPressure()
        async let exerciseType = latestExerciseType()

        return await WearableHealthDay.make(
            patientId: patientId,
            date: date,
            sourceDevice: sourceDevice,
            values: values,
            bloodPressure: bloodPressure,
            exerciseType: exerciseType
        )
    }

    /// Maps a HealthKit workout type onto the shared exercise-type names.
    private static func exerciseTypeName(for type: HKWorkoutActivityType) -> String {
        switch type {
        case .walking:                 return "Walking"
        case .running:                 return "Running"
        case .cycling:                 return "Cycling"
        case .hiking:                  return "Hiking"
        case .swimming:                return "Swimming"
        case .yoga:                    return "Yoga"
        case .traditionalStrengthTraining,
             .functionalStrengthTraining: return "Strength Training"
        case .elliptical:              return "Elliptical"
        case .rowing:                  return "Rowing"
        case .stairClimbing, .stairs:  return "Stair Climbing"
        case .basketball:              return "Basketball"
        case .soccer:                  return "Football"
        case .cricket:                 return "Cricket"
        case .tennis:                  return "Tennis"
        case .badminton:               return "Badminton"
        case .dance, .cardioDance:     return "Dance"
        case .mixedCardio:             return "Aerobics"
        case .highIntensityIntervalTraining: return "HIIT"
        case .pilates:                 return "Pilates"
        default:                       return "Other"
        }
    }

    // MARK: - Trends (detail screen)

    func trend(for metric: HealthMetricType, range: TrendRange) async -> [MetricPoint] {
        let points = await computeTrend(for: metric, range: range)
        print("📈 [HealthMetrics] \(metric.title) — \(range.title): \(points.count) points")
        for p in points {
            print("    • \(Self.logDateFormatter.string(from: p.date)) = \(String(format: "%.2f", p.value)) \(metric.unit)")
        }
        return points
    }

    private func computeTrend(for metric: HealthMetricType, range: TrendRange) async -> [MetricPoint] {
        guard isHealthDataAvailable, metric.isHealthKitBacked else { return [] }

        let params = bucketing(for: range)

        switch metric {
        case .stress:
            return []
        case .bloodPressure:
            // Plot systolic as the representative series.
            return await quantityTrend(.bloodPressureSystolic,
                                       unit: HKUnit.millimeterOfMercury(),
                                       options: .discreteAverage,
                                       params: params,
                                       scale: { $0 })
        case .sleep:
            return await categoryDurationTrend(HKCategoryType(.sleepAnalysis),
                                               params: params,
                                               unitSeconds: 3600, // hours
                                               asleepOnly: true)
        case .wellness:
            return await categoryDurationTrend(HKCategoryType(.mindfulSession),
                                               params: params,
                                               unitSeconds: 60, // minutes
                                               asleepOnly: false)
        case .calories:
            async let active = quantityTrend(.activeEnergyBurned, unit: .kilocalorie(),
                                             options: .cumulativeSum, params: params, scale: { $0 })
            async let basal = quantityTrend(.basalEnergyBurned, unit: .kilocalorie(),
                                            options: .cumulativeSum, params: params, scale: { $0 })
            return merge(await active, await basal)
        default:
            guard let id = metric.quantityTypeIdentifier else { return [] }
            let options: HKStatisticsOptions = (metric.aggregation == .cumulativeSum) ? .cumulativeSum : .discreteAverage
            return await quantityTrend(id, unit: metric.hkUnit, options: options, params: params) {
                metric.displayValue(fromHK: $0)
            }
        }
    }

    // MARK: - Bucketing

    private struct BucketParams {
        let start: Date
        let interval: DateComponents
    }

    private func bucketing(for range: TrendRange) -> BucketParams {
        let now = Date()
        switch range {
        case .daily:
            let start = calendar.startOfDay(for: now)
            return BucketParams(start: start, interval: DateComponents(hour: 1))
        case .weekly:
            let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now))!
            return BucketParams(start: start, interval: DateComponents(day: 1))
        case .monthly:
            let start = calendar.date(byAdding: .day, value: -29, to: calendar.startOfDay(for: now))!
            return BucketParams(start: start, interval: DateComponents(day: 1))
        case .yearly:
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let start = calendar.date(byAdding: .month, value: -11, to: monthStart)!
            return BucketParams(start: start, interval: DateComponents(month: 1))
        }
    }

    // MARK: - Quantity helpers

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

    private func mostRecentQuantity(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double? {
        await withCheckedContinuation { continuation in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(sampleType: HKQuantityType(id),
                                      predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
                let value = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            store.execute(query)
        }
    }

    private func latestBloodPressure() async -> (systolic: Double, diastolic: Double)? {
        async let sys = mostRecentQuantity(.bloodPressureSystolic, unit: .millimeterOfMercury())
        async let dia = mostRecentQuantity(.bloodPressureDiastolic, unit: .millimeterOfMercury())
        guard let s = await sys, let d = await dia else { return nil }
        return (s, d)
    }

    private func quantityTrend(_ id: HKQuantityTypeIdentifier,
                               unit: HKUnit,
                               options: HKStatisticsOptions,
                               params: BucketParams,
                               scale: @escaping (Double) -> Double) async -> [MetricPoint] {
        await withCheckedContinuation { continuation in
            let query = HKStatisticsCollectionQuery(quantityType: HKQuantityType(id),
                                                    quantitySamplePredicate: nil,
                                                    options: options,
                                                    anchorDate: params.start,
                                                    intervalComponents: params.interval)
            query.initialResultsHandler = { _, collection, _ in
                var points: [MetricPoint] = []
                collection?.enumerateStatistics(from: params.start, to: Date()) { stats, _ in
                    let quantity = (options == .cumulativeSum) ? stats.sumQuantity() : stats.averageQuantity()
                    if let value = quantity?.doubleValue(for: unit) {
                        points.append(MetricPoint(date: stats.startDate, value: scale(value)))
                    }
                }
                continuation.resume(returning: points)
            }
            store.execute(query)
        }
    }

    // MARK: - Category (sleep / mindful) helpers

    private func sleepHoursLastNight() async -> Double? {
        let end = Date()
        let start = calendar.date(byAdding: .hour, value: -24, to: end) ?? end
        let seconds = await asleepSeconds(start: start, end: end)
        return seconds > 0 ? seconds / 3600.0 : nil
    }

    private func mindfulMinutesToday() async -> Double? {
        let start = calendar.startOfDay(for: Date())
        let samples = await categorySamples(HKCategoryType(.mindfulSession), start: start, end: Date())
        let seconds = samples.reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
        return seconds > 0 ? seconds / 60.0 : nil
    }

    private func asleepSeconds(start: Date, end: Date) async -> Double {
        let samples = await categorySamples(HKCategoryType(.sleepAnalysis), start: start, end: end)
        let asleep: Set<Int> = [
            HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
            HKCategoryValueSleepAnalysis.asleepCore.rawValue,
            HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
            HKCategoryValueSleepAnalysis.asleepREM.rawValue
        ]
        return samples
            .filter { asleep.contains($0.value) }
            .reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
    }

    private func categorySamples(_ type: HKCategoryType, start: Date, end: Date) async -> [HKCategorySample] {
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: predicate,
                                      limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                continuation.resume(returning: (samples as? [HKCategorySample]) ?? [])
            }
            store.execute(query)
        }
    }

    /// Buckets sleep/mindful durations into the trend intervals.
    private func categoryDurationTrend(_ type: HKCategoryType,
                                       params: BucketParams,
                                       unitSeconds: Double,
                                       asleepOnly: Bool) async -> [MetricPoint] {
        let samples = await categorySamples(type, start: params.start, end: Date())
        let asleepValues: Set<Int> = [
            HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
            HKCategoryValueSleepAnalysis.asleepCore.rawValue,
            HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
            HKCategoryValueSleepAnalysis.asleepREM.rawValue
        ]

        // Build empty buckets.
        var buckets: [Date: Double] = [:]
        var cursor = params.start
        while cursor < Date() {
            buckets[cursor] = 0
            cursor = calendar.date(byAdding: params.interval, to: cursor) ?? Date()
        }

        for sample in samples {
            if asleepOnly && !asleepValues.contains(sample.value) { continue }
            let bucket = bucketStart(for: sample.startDate, params: params)
            let seconds = sample.endDate.timeIntervalSince(sample.startDate)
            buckets[bucket, default: 0] += seconds / unitSeconds
        }

        return buckets
            .map { MetricPoint(date: $0.key, value: $0.value) }
            .sorted { $0.date < $1.date }
    }

    private func bucketStart(for date: Date, params: BucketParams) -> Date {
        var candidate = params.start
        while let next = calendar.date(byAdding: params.interval, to: candidate), next <= date {
            candidate = next
        }
        return candidate
    }

    // MARK: - Utilities

    /// Adds two aligned trend series (used for total calories = active + basal).
    private func merge(_ a: [MetricPoint], _ b: [MetricPoint]) -> [MetricPoint] {
        var totals: [Date: Double] = [:]
        for p in a { totals[p.date, default: 0] += p.value }
        for p in b { totals[p.date, default: 0] += p.value }
        return totals.map { MetricPoint(date: $0.key, value: $0.value) }.sorted { $0.date < $1.date }
    }

    private func format(_ value: Double, digits: Int) -> String {
        String(format: "%.\(digits)f", value)
    }
}
