//
//  HealthKitManager.swift
//  Calmscient
//
//  Created by NFC Solutions on 11/08/26.
//

import Foundation
import HealthKit

@available(iOS 16.0, *)
final class HealthKitManager {

    static let shared = HealthKitManager()
    private let store = HKHealthStore()
    private init() {}

    var isHealthDataAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    /// How far back a "current reading" metric (heart rate, SpO2, glucose…) may look.
    /// Without this window a four-day-old sample renders as if it were taken now.
    /// Metrics declared `.discreteMostRecent` (weight, height, body fat) deliberately
    /// bypass it — the Health app also shows the last recorded value however old.
    private static let recentReadingWindow: TimeInterval = 24 * 60 * 60

    /// Category values that count as "asleep". Shared by the last-night total and the
    /// sleep chart so both agree on what sleep means.
    private static let asleepCategoryValues: Set<Int> = [
        HKCategoryValueSleepAnalysis.asleepCore.rawValue,
        HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
        HKCategoryValueSleepAnalysis.asleepREM.rawValue,
        HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
    ]

    // MARK: - Authorization

    /// Read types for every non-derived metric in the catalog.
    private var readTypes: Set<HKObjectType> {
        var types = Set<HKObjectType>()
        for metric in HealthMetric.all {
            switch metric.source {
            case .healthKit(let id):
                if let t = HKObjectType.quantityType(forIdentifier: id) { types.insert(t) }
            case .bloodPressure:
                if let s = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic) { types.insert(s) }
                if let d = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic) { types.insert(d) }
            case .sleepCategory:
                if let s = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) { types.insert(s) }
            case .derived(let kind):
                // Derived metrics can still lean on a real HK type as a proxy:
                if kind == .stress, let hrv = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) { types.insert(hrv) }
                if kind == .bmr, let basal = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned) { types.insert(basal) }
                if kind == .wellness, let mind = HKObjectType.categoryType(forIdentifier: .mindfulSession) { types.insert(mind) }
            }
        }
        // For BMR formula fallback we also want these characteristics/quantities:
        if let dob = HKObjectType.characteristicType(forIdentifier: .dateOfBirth) { types.insert(dob) }
        if let sex = HKObjectType.characteristicType(forIdentifier: .biologicalSex) { types.insert(sex) }

        // Workouts back the `exerciseType` field of the wearable-data upload. This is the only
        // read type not derived from the metric catalog, because no dashboard row displays it.
        // Adding it means already-authorised users see the Health permission sheet once more,
        // listing just this row.
        types.insert(HKObjectType.workoutType())

        return types
    }

    /// Whether asking for authorization would actually put anything on screen.
    ///
    /// `.shouldRequest` means at least one requested type has never been answered by this user.
    /// Note this says nothing about whether access was *granted* — Apple deliberately hides read
    /// authorization so an app cannot detect what the user is withholding. It only answers "would
    /// the sheet appear?", which is exactly what a pre-prompt needs to know.
    ///
    /// Lives here because `store` and `readTypes` are private to this file.
    func needsAuthorizationRequest() async -> Bool {
        guard isHealthDataAvailable else { return false }
        let types = readTypes
        return await withCheckedContinuation { cont in
            store.getRequestStatusForAuthorization(toShare: [], read: types) { status, _ in
                cont.resume(returning: status == .shouldRequest)
            }
        }
    }

    func requestAuthorization() async throws {
        guard isHealthDataAvailable else {
            throw NSError(domain: "HealthKit", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Health data is not available on this device."])
        }
        try await store.requestAuthorization(toShare: [], read: readTypes)
    }

    // MARK: - Latest value (dashboard rows)

    /// The value shown on a dashboard row. This now honours `metric.aggregation`, which
    /// is what makes the rows agree with the Health app:
    ///
    ///  - `.cumulativeSum`      → today's TOTAL (Steps, Distance, Active Calories,
    ///                            Exercise, Hydration). HealthKit stores these as dozens
    ///                            of small samples per day, so the newest sample alone is
    ///                            a fragment of the day, not the day.
    ///  - `.discreteAverage`    → the newest reading inside the last 24h (Heart Rate,
    ///                            SpO2, Resting HR, Respiratory Rate, HRV, Glucose).
    ///  - `.discreteMostRecent` → the newest reading with no time limit (Weight, Height,
    ///                            Body Fat) — matching Health, which keeps showing your
    ///                            last weigh-in weeks later.
    func latestValue(for metric: HealthMetric) async -> HealthLatestValue {
        switch metric.source {
        case .healthKit(let id):
            switch metric.aggregation {
            case .cumulativeSum:
                return await todaySum(id: id, metric: metric)
            case .discreteAverage:
                return await latestQuantity(id: id, metric: metric, within: Self.recentReadingWindow)
            case .discreteMostRecent:
                return await latestQuantity(id: id, metric: metric, within: nil)
            }
        case .bloodPressure:
            return await latestBloodPressure()
        case .sleepCategory:
            return await lastNightSleepHours()
        case .derived(let kind):
            return await derivedLatest(kind: kind, metric: metric)
        }
    }

    /// Newest sample for a type. `window` limits how far back to look; `nil` means
    /// "however old", which is what Weight / Height / Body Fat want.
    private func latestQuantity(id: HKQuantityTypeIdentifier,
                                metric: HealthMetric,
                                within window: TimeInterval?) async -> HealthLatestValue {
        guard let type = HKQuantityType.quantityType(forIdentifier: id), let unit = metric.hkUnit else {
            return HealthLatestValue(value: nil, displayText: "--")
        }
        // `options: []` (not .strictStartDate) so a sample that began just before the
        // window but is still the newest reading is not silently dropped.
        let predicate: NSPredicate? = window.map { seconds in
            HKQuery.predicateForSamples(withStart: Date().addingTimeInterval(-seconds),
                                        end: Date(),
                                        options: [])
        }
        let sort = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]
        let sample: HKQuantitySample? = await withCheckedContinuation { cont in
            let q = HKSampleQuery(sampleType: type, predicate: predicate, limit: 1, sortDescriptors: sort) { _, samples, _ in
                cont.resume(returning: samples?.first as? HKQuantitySample)
            }
            store.execute(q)
        }
        guard let sample else { return HealthLatestValue(value: nil, displayText: "--") }
        var value = sample.quantity.doubleValue(for: unit)
        if unit == .percent() { value *= 100 }   // HK percent is 0...1
        return HealthLatestValue(value: value, displayText: format(value, metric: metric))
    }

    /// Today's total from midnight to now — the same number the Health app's summary
    /// tile shows for Steps, Distance, Active Calories, Exercise and Hydration.
    private func todaySum(id: HKQuantityTypeIdentifier, metric: HealthMetric) async -> HealthLatestValue {
        guard let type = HKQuantityType.quantityType(forIdentifier: id), let unit = metric.hkUnit else {
            return HealthLatestValue(value: nil, displayText: "--")
        }
        // HKStatisticsQuery(options: .cumulativeSum) throws on a non-cumulative type,
        // so a catalog entry declared `.cumulativeSum` by mistake degrades to the newest
        // sample instead of crashing.
        guard type.aggregationStyle == .cumulative else {
            return await latestQuantity(id: id, metric: metric, within: Self.recentReadingWindow)
        }
        let start = Calendar.current.startOfDay(for: Date())
        let total = await sumQuantity(type: type, unit: unit, start: start, end: Date())
        // A daily total of nothing is a real answer ("0 steps"), not missing data ("--").
        let value = total ?? 0
        return HealthLatestValue(value: value, displayText: format(value, metric: metric))
    }

    /// Sums a cumulative quantity type over a date range. Returns nil when there are no
    /// samples at all, so callers can tell "no data" from "zero".
    private func sumQuantity(type: HKQuantityType, unit: HKUnit, start: Date, end: Date) async -> Double? {
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [])
        return await withCheckedContinuation { cont in
            let q = HKStatisticsQuery(quantityType: type,
                                      quantitySamplePredicate: predicate,
                                      options: .cumulativeSum) { _, stats, _ in
                cont.resume(returning: stats?.sumQuantity()?.doubleValue(for: unit))
            }
            store.execute(q)
        }
    }

    // MARK: - Time series (charts) — the core of the analytics screen

    /// Returns bucketed data points for a metric across a timeframe.
    /// Daily   → 24 hourly (or per-day) buckets for the last day/week
    /// Weekly  → 7 daily buckets
    /// Monthly → ~12 monthly buckets
    /// Yearly  → yearly buckets
    func series(for metric: HealthMetric, timeframe: HealthTimeframe) async -> [HealthDataPoint] {
        switch metric.source {
        case .healthKit(let id):
            return await quantitySeries(id: id, metric: metric, timeframe: timeframe)
        case .bloodPressure:
            // Chart systolic as the primary line; diastolic can be a second series.
            return await quantitySeries(id: .bloodPressureSystolic, metric: metric, timeframe: timeframe)
        case .sleepCategory:
            return await sleepSeries(timeframe: timeframe)
        case .derived(let kind):
            return await derivedSeries(kind: kind, metric: metric, timeframe: timeframe)
        }
    }

    private func quantitySeries(id: HKQuantityTypeIdentifier,
                                metric: HealthMetric,
                                timeframe: HealthTimeframe) async -> [HealthDataPoint] {
        guard let type = HKQuantityType.quantityType(forIdentifier: id), let unit = metric.hkUnit else { return [] }

        let (anchor, interval, start) = bucketing(for: timeframe)
        let options: HKStatisticsOptions = (metric.aggregation == .cumulativeSum) ? .cumulativeSum : .discreteAverage

        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)

        let collection: HKStatisticsCollection? = await withCheckedContinuation { cont in
            let q = HKStatisticsCollectionQuery(quantityType: type,
                                                quantitySamplePredicate: predicate,
                                                options: options,
                                                anchorDate: anchor,
                                                intervalComponents: interval)
            q.initialResultsHandler = { _, result, _ in cont.resume(returning: result) }
            store.execute(q)
        }
        guard let collection else { return [] }

        var points: [HealthDataPoint] = []
        collection.enumerateStatistics(from: start, to: Date()) { stats, _ in
            let q: HKQuantity? = (metric.aggregation == .cumulativeSum) ? stats.sumQuantity() : stats.averageQuantity()
            var v = q?.doubleValue(for: unit) ?? 0
            if unit == .percent() { v *= 100 }
            points.append(HealthDataPoint(date: stats.startDate,
                                          value: v,
                                          label: Self.axisLabel(for: stats.startDate, timeframe: timeframe)))
        }
        return points
    }

    /// Bucket anchor + interval + window start for each timeframe.
    private func bucketing(for timeframe: HealthTimeframe) -> (anchor: Date, interval: DateComponents, start: Date) {
        let cal = Calendar.current
        let now = Date()
        switch timeframe {
        case .daily:   // last 24h in hourly buckets
            let start = cal.date(byAdding: .hour, value: -24, to: now)!
            return (cal.startOfDay(for: now), DateComponents(hour: 1), start)
        case .weekly:  // last 7 days in daily buckets
            let start = cal.date(byAdding: .day, value: -7, to: now)!
            return (cal.startOfDay(for: now), DateComponents(day: 1), start)
        case .monthly: // last 12 months in monthly buckets
            let start = cal.date(byAdding: .month, value: -12, to: now)!
            let anchor = cal.date(from: cal.dateComponents([.year, .month], from: now))!
            return (anchor, DateComponents(month: 1), start)
        case .yearly:  // last 5 years in yearly buckets
            let start = cal.date(byAdding: .year, value: -5, to: now)!
            let anchor = cal.date(from: cal.dateComponents([.year], from: now))!
            return (anchor, DateComponents(year: 1), start)
        }
    }

    static func axisLabel(for date: Date, timeframe: HealthTimeframe) -> String {
        let f = DateFormatter()
        switch timeframe {
        case .daily:   f.dateFormat = "ha"     // 12AM, 2AM...
        case .weekly:  f.dateFormat = "EEE"    // Mon, Tue...
        case .monthly: f.dateFormat = "MMM"    // Jan, Feb...
        case .yearly:  f.dateFormat = "yyyy"   // 2024...
        }
        return f.string(from: date)
    }

    // MARK: - Sleep (category type, not quantity)

    /// Last night's sleep total, the way the Health app reports it.
    ///
    /// The old version took `sleepSeries(.daily).last`, which bucketed by calendar day —
    /// so a night running 11pm→7am was split in two and the row showed only the hours
    /// after midnight. Instead we sum one *night window*: 6pm the previous evening
    /// through noon, which is the convention Health uses to decide which day a night
    /// belongs to. Afternoon naps fall outside it, as they should.
    private func lastNightSleepHours() async -> HealthLatestValue {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            return HealthLatestValue(value: nil, displayText: "--")
        }
        let cal = Calendar.current
        let now = Date()
        // Noon today is the anchor; before noon we clamp the end to "now" so someone
        // checking at 6am still sees the night they just finished.
        guard let noonToday = cal.date(bySettingHour: 12, minute: 0, second: 0, of: now),
              let windowStart = cal.date(byAdding: .hour, value: -18, to: noonToday) else {
            return HealthLatestValue(value: nil, displayText: "--")
        }
        let windowEnd = min(noonToday, now)
        guard windowEnd > windowStart else { return HealthLatestValue(value: nil, displayText: "--") }

        // `options: []` so a session that began before 6pm still counts; its duration is
        // then clamped to the window below so the overlap isn't double-counted.
        let predicate = HKQuery.predicateForSamples(withStart: windowStart, end: windowEnd, options: [])
        let samples: [HKCategorySample] = await withCheckedContinuation { cont in
            let q = HKSampleQuery(sampleType: type, predicate: predicate,
                                  limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, s, _ in
                cont.resume(returning: (s as? [HKCategorySample]) ?? [])
            }
            store.execute(q)
        }

        let asleep = samples.filter { Self.asleepCategoryValues.contains($0.value) }
        guard !asleep.isEmpty else { return HealthLatestValue(value: nil, displayText: "--") }

        let seconds = asleep.reduce(0.0) { total, sample in
            let from = max(sample.startDate, windowStart)
            let to   = min(sample.endDate, windowEnd)
            return total + max(0, to.timeIntervalSince(from))
        }
        let hrs = seconds / 3600.0
        return HealthLatestValue(value: hrs, displayText: String(format: "%.1f hrs", hrs))
    }

    private func sleepSeries(timeframe: HealthTimeframe) async -> [HealthDataPoint] {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return [] }
        let cal = Calendar.current
        let (_, _, start) = bucketing(for: timeframe)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)

        let samples: [HKCategorySample] = await withCheckedContinuation { cont in
            let q = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, s, _ in
                cont.resume(returning: (s as? [HKCategorySample]) ?? [])
            }
            store.execute(q)
        }
        // Sum "asleep" durations per day bucket.
        var byDay: [Date: TimeInterval] = [:]
        for s in samples where Self.asleepCategoryValues.contains(s.value) {
            let day = cal.startOfDay(for: s.startDate)
            byDay[day, default: 0] += s.endDate.timeIntervalSince(s.startDate)
        }
        return byDay.keys.sorted().map { day in
            HealthDataPoint(date: day, value: byDay[day]! / 3600.0,
                            label: Self.axisLabel(for: day, timeframe: timeframe))
        }
    }

    // MARK: - Blood pressure (correlation)

    private func latestBloodPressure() async -> HealthLatestValue {
        async let sys = latestScalar(.bloodPressureSystolic, unit: .millimeterOfMercury())
        async let dia = latestScalar(.bloodPressureDiastolic, unit: .millimeterOfMercury())
        let (s, d) = await (sys, dia)
        guard let s, let d else { return HealthLatestValue(value: nil, displayText: "--") }
        return HealthLatestValue(value: s, displayText: "\(Int(s))/\(Int(d)) mmHg")
    }

    private func latestScalar(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double? {
        guard let type = HKQuantityType.quantityType(forIdentifier: id) else { return nil }
        let sort = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]
        let sample: HKQuantitySample? = await withCheckedContinuation { cont in
            let q = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: sort) { _, s, _ in
                cont.resume(returning: s?.first as? HKQuantitySample)
            }
            store.execute(q)
        }
        return sample?.quantity.doubleValue(for: unit)
    }

    // MARK: - Derived metrics (Stress / BMR / Wellness) — product logic lives here

    private func derivedLatest(kind: DerivedKind, metric: HealthMetric) async -> HealthLatestValue {
        switch kind {
        case .stress:
            // Proxy: lower HRV → higher stress. Replace with your backend score if you have one.
            let hrv = await latestScalar(.heartRateVariabilitySDNN, unit: .secondUnit(with: .milli))
            guard let hrv else { return HealthLatestValue(value: nil, displayText: "--") }
            let score = max(0, min(100, 100 - hrv))   // placeholder mapping — tune to your model
            return HealthLatestValue(value: score, displayText: "\(Int(score)) score")
        case .bmr:
            // Resting Energy = today's TOTAL basal energy burned, matching the Health
            // app's "Resting Energy" tile. Reading a single basalEnergyBurned sample
            // showed a per-interval fragment (tens of kcal) instead of ~1,400–1,800.
            guard let type = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned) else {
                return HealthLatestValue(value: nil, displayText: "--")
            }
            let start = Calendar.current.startOfDay(for: Date())
            let total = await sumQuantity(type: type, unit: .kilocalorie(), start: start, end: Date())
            guard let total else { return HealthLatestValue(value: nil, displayText: "--") }
            return HealthLatestValue(value: total, displayText: "\(Int(total)) kcal")
        case .wellness:
            // Mindful minutes today, if you record them; else backend/business value.
            let mins = await mindfulMinutesToday()
            return HealthLatestValue(value: mins, displayText: "\(Int(mins)) min")
        }
    }

    private func derivedSeries(kind: DerivedKind, metric: HealthMetric, timeframe: HealthTimeframe) async -> [HealthDataPoint] {
        // Derived series are usually filled from your BACKEND history (Step 8),
        // or computed from a proxy series. Return [] here and let the ViewModel
        // merge backend history in. Left intentionally minimal.
        return []
    }

    private func mindfulMinutesToday() async -> Double {
        guard let type = HKObjectType.categoryType(forIdentifier: .mindfulSession) else { return 0 }
        let start = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)
        let samples: [HKCategorySample] = await withCheckedContinuation { cont in
            let q = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, s, _ in
                cont.resume(returning: (s as? [HKCategorySample]) ?? [])
            }
            store.execute(q)
        }
        return samples.reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) } / 60.0
    }

    // MARK: - Formatting

    /// Grouped whole numbers, so a step total reads "1,953 steps" like the Health app
    /// rather than "1953 steps".
    private static let wholeNumberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return f
    }()

    private func format(_ value: Double, metric: HealthMetric) -> String {
        switch metric.aggregation {
        case .cumulativeSum where metric.unit == "steps":
            let text = Self.wholeNumberFormatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
            return "\(text) \(metric.unit)"
        case .cumulativeSum where metric.unit == "min" || metric.unit == "kcal":
            // Exercise minutes and calories are whole numbers in Health, not "12.0 min".
            let text = Self.wholeNumberFormatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
            return "\(text) \(metric.unit)"
        case .cumulativeSum: return String(format: "%.1f %@", value, metric.unit)
        default:
            if metric.unit == "%" || metric.unit == "ms" || metric.unit == "bpm" {
                return "\(Int(value)) \(metric.unit)"
            }
            return String(format: "%.1f %@", value, metric.unit)
        }
    }

    // MARK: - Background delivery

    /// Retained so a later call can stop them.
    ///
    /// Without this, re-arming after the user grants access would leave the first, useless set of
    /// queries running alongside the new one — every future write to HealthKit would wake the app
    /// twice, forever, for no extra data.
    private var observerQueries: [HKObserverQuery] = []

    /// Stops every observer query started by `startObserverQueries(for:frequency:onChange:)`.
    ///
    /// Does **not** disable background delivery — that survives process death and is turned off
    /// separately, on logout.
    func stopObserverQueries() {
        for query in observerQueries {
            store.stop(query)
        }
        observerQueries.removeAll()
    }

    /// Starts a long-lived observer query per type and asks HealthKit to keep delivering while the
    /// app is not running.
    ///
    /// Two rules govern this and both are unforgiving:
    ///
    ///  - `onChange` is handed HealthKit's completion handler and **must** call it, on every path
    ///    including failure. iOS reads a missing acknowledgement as the app being unable to cope
    ///    and quietly stops waking it.
    ///  - Observer queries do not survive a process restart, so this has to run on every launch.
    ///    `enableBackgroundDelivery` is the half that does persist.
    ///
    /// Frequency is `.hourly` rather than `.immediate` deliberately: a Watch writes heart rate
    /// every few minutes, and immediate delivery would mean dozens of wake-ups a day for a
    /// cadence that only needs four.
    func startObserverQueries(for types: [HKObjectType],
                              frequency: HKUpdateFrequency = .hourly,
                              onChange: @escaping (@escaping () -> Void) -> Void) {
        guard isHealthDataAvailable else { return }

        // Never stack a second set on top of an existing one.
        stopObserverQueries()

        for type in types {
            guard let sampleType = type as? HKSampleType else { continue }

            let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { _, completionHandler, error in
                if let error = error {
                    print("HealthKit observer error (\(sampleType.identifier)): \(error.localizedDescription)")
                    completionHandler()
                    return
                }
                onChange(completionHandler)
            }
            store.execute(query)
            observerQueries.append(query)

            store.enableBackgroundDelivery(for: sampleType, frequency: frequency) { success, error in
                if let error = error {
                    print("HealthKit background delivery failed (\(sampleType.identifier)): \(error.localizedDescription)")
                } else {
                    print("HealthKit background delivery \(success ? "enabled" : "unavailable") (\(sampleType.identifier))")
                }
            }
        }
    }

    // MARK: - Reads for the wearable-data upload
    //
    // Everything below is additive and exists only to fill fields of the backend payload that the
    // dashboard has no row for. Nothing here changes what `latestValue(for:)` or `series(for:)`
    // return, so the Health Metrics screen behaves exactly as before.
    //
    // These live inside the class rather than in an extension in the sync folder because `store`,
    // `latestScalar` and `sumQuantity` are `private`, and Swift scopes that to the file.

    /// Systolic and diastolic as separate numbers.
    ///
    /// `latestBloodPressure()` puts systolic in `value` and "120/80 mmHg" in `displayText`, which
    /// is right for a dashboard row but leaves the upload with no way to reach diastolic as a
    /// number. This exposes both without touching that method.
    func latestBloodPressurePair() async -> (systolic: Double?, diastolic: Double?) {
        async let sys = latestScalar(.bloodPressureSystolic, unit: .millimeterOfMercury())
        async let dia = latestScalar(.bloodPressureDiastolic, unit: .millimeterOfMercury())
        return await (sys, dia)
    }

    /// Today's active, basal and combined energy in one pass.
    ///
    /// Returned together rather than as three calls because the upload needs `activeCalories`,
    /// `bmr` and `totalCalories`, and querying basal energy twice inside a background wake-up's
    /// short window is waste. The sum is confirmed against the API example: 420 active + 1680
    /// basal = 2100 total.
    ///
    /// `total` is nil only when neither type has a sample today, so a device reporting just one
    /// of the two still contributes a number instead of a gap.
    func todayEnergySummary() async -> (active: Double?, basal: Double?, total: Double?) {
        async let activeTask = todaySum(identifier: .activeEnergyBurned, unit: .kilocalorie())
        async let basalTask  = todaySum(identifier: .basalEnergyBurned,  unit: .kilocalorie())
        let (active, basal) = await (activeTask, basalTask)

        guard active != nil || basal != nil else {
            return (active, basal, nil)
        }
        return (active, basal, (active ?? 0) + (basal ?? 0))
    }

    /// Sums a cumulative type from midnight to now. Nil when there are no samples at all today,
    /// which lets a caller tell "no data" from a genuine zero.
    private func todaySum(identifier: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double? {
        guard let type = HKQuantityType.quantityType(forIdentifier: identifier) else { return nil }
        let start = Calendar.current.startOfDay(for: Date())
        return await sumQuantity(type: type, unit: unit, start: start, end: Date())
    }

    /// The activity name of today's most recent workout, e.g. "Walking".
    ///
    /// Restricted to today deliberately: reporting last Tuesday's run next to this morning's
    /// vitals would misrepresent the snapshot. Nil when nothing was recorded today.
    func todayLatestWorkoutTypeName() async -> String? {
        let start = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: [])
        let sort = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]

        let workout: HKWorkout? = await withCheckedContinuation { cont in
            let q = HKSampleQuery(sampleType: HKObjectType.workoutType(),
                                  predicate: predicate,
                                  limit: 1,
                                  sortDescriptors: sort) { _, samples, _ in
                cont.resume(returning: samples?.first as? HKWorkout)
            }
            store.execute(q)
        }

        guard let workout = workout else { return nil }
        return Self.workoutTypeName(for: workout.workoutActivityType)
    }

    /// Name for the workout kinds a Calmscient patient realistically records.
    ///
    /// HealthKit defines around eighty activity types and exposes no display name for any of
    /// them, so this maps the common ones and lets the rest fall through to "Other" — a backend
    /// row reading "Other" is more useful than one reading "type 3000".
    static func workoutTypeName(for type: HKWorkoutActivityType) -> String {
        switch type {
        case .walking:                        return "Walking"
        case .running:                        return "Running"
        case .cycling:                        return "Cycling"
        case .swimming:                       return "Swimming"
        case .hiking:                         return "Hiking"
        case .yoga:                           return "Yoga"
        case .pilates:                        return "Pilates"
        case .coreTraining:                   return "Core Training"
        case .functionalStrengthTraining:     return "Strength Training"
        case .traditionalStrengthTraining:    return "Strength Training"
        case .highIntensityIntervalTraining:  return "HIIT"
        case .elliptical:                     return "Elliptical"
        case .rowing:                         return "Rowing"
        case .stairClimbing, .stairs:         return "Stair Climbing"
        case .dance, .cardioDance:            return "Dance"
        case .mixedCardio:                    return "Cardio"
        case .flexibility:                    return "Flexibility"
        case .cooldown:                       return "Cooldown"
        case .preparationAndRecovery:         return "Warm Up"
        case .mindAndBody:                    return "Mind and Body"
        case .wheelchairWalkPace,
             .wheelchairRunPace:              return "Wheelchair"
        default:                              return "Other"
        }
    }

    /// A human-readable name for the hardware that produced the most recent activity data.
    ///
    /// Heart rate is checked first because only a Watch writes it, so a Watch user is reported as
    /// "Apple Watch" rather than "iPhone"; step count is the fallback since an iPhone writes that
    /// on its own. `device?.name` is the hardware, while `sourceRevision.source.name` is the app
    /// that wrote the sample — the useful second choice for a third-party tracker that syncs
    /// without declaring a device.
    ///
    /// Nil when there are no samples at all; the caller decides what to send instead.
    func latestSampleSourceName() async -> String? {
        let identifiers: [HKQuantityTypeIdentifier] = [.heartRate, .stepCount]

        for identifier in identifiers {
            guard let type = HKQuantityType.quantityType(forIdentifier: identifier) else { continue }
            let sort = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]

            let sample: HKSample? = await withCheckedContinuation { cont in
                let q = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: sort) { _, samples, _ in
                    cont.resume(returning: samples?.first)
                }
                store.execute(q)
            }

            if let name = sample?.device?.name, !name.isEmpty { return name }
            if let name = sample?.sourceRevision.source.name, !name.isEmpty { return name }
        }

        return nil
    }
}
