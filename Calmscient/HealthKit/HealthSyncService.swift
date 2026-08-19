//
//  HealthSyncService.swift
//  Calmscient
//
//  Created by NFC Solutions on 19/08/26.
//

import Foundation

/// Uploads the HealthKit readings the app has just fetched to
/// `POST patients/api/v1/health/wearable-data`, at most once every five hours.
///
/// ## Why a throttle and not a timer
///
/// iOS does not let an app wake itself every five hours on its own; a `Timer` only ticks
/// while the process is alive and is killed with the app. So instead of scheduling the
/// work, this service is *offered* the work at every natural opportunity — the Health
/// Metrics screen finishing a load, and the app coming to the foreground — and drops the
/// offer unless five hours have passed since the last **successful** upload. The stamp
/// lives in `UserDefaults`, so the gap is honoured across relaunches rather than resetting
/// every cold start.
///
/// The consequence worth knowing: the upload happens the first time the app is opened
/// after the five hours elapse, not on the stroke of the fifth hour. A true background
/// schedule would need `BGTaskScheduler` plus the background-fetch capability, and even
/// then iOS decides when it actually runs.
///
/// A failed upload deliberately does not stamp the clock, so the next opportunity retries
/// instead of waiting out another five hours.
@available(iOS 16.0, *)
@MainActor
final class HealthSyncService {

    static let shared = HealthSyncService()
    private init() {}

    /// Minimum gap between two successful uploads.
    static let syncInterval: TimeInterval = 5 * 60 * 60

    /// Guards against a second sync starting while the first is still in flight — the
    /// screen load and a foreground event can easily land within the same second.
    private var isSyncing = false

    // MARK: - Last-sync stamp
    //
    // Keyed by patient id: switching accounts on a shared device must not inherit the
    // previous patient's clock and skip that patient's first upload.

    private func lastSyncKey(patientId: Int) -> String { "health.wearable.lastSyncAt.\(patientId)" }

    private func lastSyncDate(patientId: Int) -> Date? {
        let seconds = UserDefaults.standard.double(forKey: lastSyncKey(patientId: patientId))
        return seconds > 0 ? Date(timeIntervalSince1970: seconds) : nil
    }

    private func stampSync(patientId: Int, at date: Date = Date()) {
        UserDefaults.standard.set(date.timeIntervalSince1970, forKey: lastSyncKey(patientId: patientId))
    }

    /// Clears the throttle for the current patient. Call on logout so the next patient
    /// on this device — or the same patient signing back in — uploads immediately.
    func resetThrottle() {
        guard let patientId = ApplicationSharedInfo.shared.loginResponse?.patientID else { return }
        UserDefaults.standard.removeObject(forKey: lastSyncKey(patientId: patientId))
    }

    private func isDue(patientId: Int) -> Bool {
        guard let last = lastSyncDate(patientId: patientId) else { return true }
        // A clock moved backwards (manual date change, timezone travel) leaves a stamp in
        // the future. Treat that as due rather than locking the upload out indefinitely.
        let elapsed = Date().timeIntervalSince(last)
        return elapsed >= Self.syncInterval || elapsed < 0
    }

    // MARK: - Entry points

    /// Fire-and-forget upload, skipped unless five hours have passed.
    ///
    /// - Parameter latest: values the caller has already read from HealthKit, keyed by
    ///   `HealthMetric.id`. Pass the Health Metrics screen's cache to avoid reading every
    ///   metric a second time; pass `nil` (the default) and the service reads for itself,
    ///   which is what the foreground trigger does.
    func syncIfDue(latest: [String: HealthLatestValue]? = nil) {
        guard let patientId = ApplicationSharedInfo.shared.loginResponse?.patientID,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken,
              !token.isEmpty,
              HealthKitManager.shared.isHealthDataAvailable,
              !isSyncing,
              isDue(patientId: patientId)
        else { return }

        isSyncing = true
        Task {
            defer { isSyncing = false }
            await sync(patientId: patientId, token: token, latest: latest)
        }
    }

    /// Uploads now, ignoring the throttle. Useful for a manual "sync" action or debugging.
    @discardableResult
    func syncNow(latest: [String: HealthLatestValue]? = nil) async -> Bool {
        guard let patientId = ApplicationSharedInfo.shared.loginResponse?.patientID,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken,
              !token.isEmpty,
              HealthKitManager.shared.isHealthDataAvailable
        else { return false }
        return await sync(patientId: patientId, token: token, latest: latest)
    }

    // MARK: - The upload

    @discardableResult
    private func sync(patientId: Int, token: String, latest: [String: HealthLatestValue]?) async -> Bool {
        let payload = await buildPayload(patientId: patientId, latest: latest)

        // Nothing to say — no watch paired, permissions denied, or a Simulator. Don't
        // stamp the clock: the moment real data appears we want to send it.
        guard !payload.hasNoReadings else {
            print("⌚️ Wearable sync skipped — no HealthKit readings available.")
            return false
        }

        let params: [String: Any]
        do {
            params = try payload.jsonObject()
        } catch {
            print("⌚️ Wearable sync failed to encode payload: \(error.localizedDescription)")
            return false
        }

        let succeeded: Bool = await withCheckedContinuation { continuation in
            // `view` is nil on purpose: this runs unattended, so a failure must not put a
            // toast or a spinner over whatever screen the user happens to be on.
            APIService.saveWearableDataAPICalling(nil, params: params, accessToken: token) { response in
                continuation.resume(returning: Self.isSuccess(response))
            }
        }

        if succeeded {
            stampSync(patientId: patientId)
            print("⌚️ Wearable data saved. Next upload no earlier than "
                  + "\(Date().addingTimeInterval(Self.syncInterval)).")
        } else {
            print("⌚️ Wearable sync failed — will retry at the next opportunity.")
        }
        return succeeded
    }

    /// The endpoint answers `{"statusResponse":{"responseCode":200,...}}` on success, and
    /// `APIService` hands back an `"Error: …"` string for transport failures.
    private static func isSuccess(_ response: AnyObject) -> Bool {
        if let text = response as? String {
            print("⌚️ Wearable sync response: \(text)")
            return false
        }
        guard let dict = response as? [String: Any],
              let status = dict["statusResponse"] as? [String: Any] else { return false }
        let code = (status["responseCode"] as? Int) ?? Int(status["responseCode"] as? String ?? "")
        return code == 200
    }

    // MARK: - HealthKit → request body

    private func buildPayload(patientId: Int,
                              latest: [String: HealthLatestValue]?) async -> WearableSavePayload {

        // Read only what the caller didn't already have.
        var values: [String: HealthLatestValue] = latest ?? [:]
        if latest == nil {
            for metric in HealthMetric.all {
                values[metric.id] = await HealthKitManager.shared.latestValue(for: metric)
            }
        }

        // Systolic/diastolic and the sleep stages aren't on the dashboard rows, so they
        // are always read here regardless of what the caller passed in.
        async let bloodPressure = HealthKitManager.shared.latestBloodPressurePair()
        async let sleepStages = HealthKitManager.shared.lastNightSleepBreakdown()
        async let device = HealthKitManager.shared.sourceDeviceName()
        let (bp, sleep, sourceDevice) = await (bloodPressure, sleepStages, device)

        func number(_ id: String) -> Double? { values[id]?.value }
        func int(_ id: String) -> Int? { number(id).map { Int($0.rounded()) } }

        var vitals = WearableSavePayload.Vitals()
        vitals.heartRate = int("heart_rate")
        vitals.spo2 = Self.round1(number("spo2"))
        vitals.stress = int("stress")
        vitals.restingHeartRate = int("resting_hr")
        vitals.respiratoryRate = Self.round1(number("respiratory_rate"))
        vitals.bloodPressureSystolic = bp.map { Int($0.systolic.rounded()) }
        vitals.bloodPressureDiastolic = bp.map { Int($0.diastolic.rounded()) }

        var activity = WearableSavePayload.Activity()
        activity.steps = int("steps")
        activity.distanceKm = Self.round1(number("distance"))
        activity.caloriesBurned = int("active_calories")
        activity.activeMinutes = int("exercise")

        var body = WearableSavePayload.Body()
        body.weightKg = Self.round1(number("weight"))
        body.heightCm = Self.round1(number("height"))
        body.bodyFatPercentage = Self.round1(number("body_fat"))
        body.bmi = Self.bmi(weightKg: number("weight"), heightCm: number("height"))

        var sleepBody = WearableSavePayload.Sleep()
        sleepBody.totalSleepHours = Self.round1(sleep?.totalHours)
        // Stage fields go out only when the tracker actually staged the night — an
        // unstaged night would otherwise report three convincing-looking zeros.
        if let sleep, sleep.deepHours + sleep.lightHours + sleep.remHours > 0 {
            sleepBody.deepSleepHours = Self.round1(sleep.deepHours)
            sleepBody.lightSleepHours = Self.round1(sleep.lightHours)
            sleepBody.remSleepHours = Self.round1(sleep.remHours)
        }

        var nutrition = WearableSavePayload.Nutrition()
        nutrition.waterIntakeLiters = Self.round1(number("hydration"))

        return WearableSavePayload(
            patientId: patientId,
            timestamp: Self.timestampFormatter.string(from: Date()),
            sourceDevice: sourceDevice,
            vitals: vitals.isEmpty ? nil : vitals,
            activity: activity.isEmpty ? nil : activity,
            body: body.isEmpty ? nil : body,
            sleep: sleepBody.isEmpty ? nil : sleepBody,
            nutrition: nutrition.isEmpty ? nil : nutrition,
            // No source in the app for mood / energy / recovery yet. The mindful-minutes
            // "Wellness" row has no field in this contract, so the object stays out
            // rather than going up half-populated.
            wellness: nil
        )
    }

    // MARK: - Helpers

    /// `2026-08-19T16:30:00Z` — UTC, matching the format the endpoint's examples use.
    private static let timestampFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return f
    }()

    /// Keeps one decimal place. HealthKit unit conversion produces values like
    /// `97.99999999999999`, which is noise in a stored record.
    private static func round1(_ value: Double?) -> Double? {
        guard let value else { return nil }
        return (value * 10).rounded() / 10
    }

    /// BMI isn't a HealthKit read here — it's derived from the weight and height already
    /// being sent, so it's only present when both of those are.
    private static func bmi(weightKg: Double?, heightCm: Double?) -> Double? {
        guard let weightKg, let heightCm, heightCm > 0 else { return nil }
        let metres = heightCm / 100.0
        return round1(weightKg / (metres * metres))
    }
}
