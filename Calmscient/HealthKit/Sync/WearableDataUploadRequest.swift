//
//  WearableDataUploadRequest.swift
//  Calmscient
//
//  Created by NFC Solutions on 19/08/26.
//

import Foundation

/// The body of `POST patients/api/v1/health/wearable-data`.
///
/// Field names mirror the GET response models in `WearableDataAPICodables.swift` exactly, and
/// every metric is a string — that is the contract, not an accident.
///
/// It is a **separate type** rather than a reuse of those GET classes on purpose. Those are
/// decode-oriented (`let` properties, hand-written `init(from:)`, plus a `date` field the POST
/// does not accept), so making them constructible would mean editing models the Health Metrics
/// and date-range screens already depend on. A mirror costs a few lines and keeps request and
/// response free to diverge without either breaking the other.
///
/// Missing readings are `""`, never `"0"`. That distinction matters more than it looks: a
/// clinician reading "weight 0 kg" or "heart rate 0" sees a measurement, not a gap.
struct WearableDataUploadRequest: Encodable {

    let patientId: Int

    /// Epoch **milliseconds** as a string, e.g. `"1787116200000"` — the slot boundary, not the
    /// moment of sending, so a retry produces a byte-identical value.
    let timestamp: String

    /// Derived from the `HKSource` of the samples: "Apple Watch" when the data came from a
    /// paired Watch, "iPhone" otherwise.
    let sourceDevice: String

    let vitals: Vitals
    let activity: Activity
    let body: Body
    let sleep: Sleep
    let nutrition: Nutrition
    let wellness: Wellness

    /// True when HealthKit returned nothing at all — every field is `""`.
    ///
    /// Worth checking before uploading. Apple gives no way to query read authorization, so a user
    /// who was never asked, or who tapped Allow without turning any toggle on, is
    /// indistinguishable from one who genuinely has no data — and both produce a row of empty
    /// strings. Sending those fills a clinical record with blank entries and makes the integration
    /// look broken to whoever is reading it.
    var containsNoReadings: Bool {
        let values = [
            vitals.heartRate, vitals.stressLevel, vitals.restingHeartRate, vitals.spo2,
            vitals.respiratoryRate, vitals.systolicPressure, vitals.diastolicPressure, vitals.hrv,
            activity.steps, activity.distance, activity.activeCalories, activity.totalCalories,
            activity.exerciseMinutes, activity.exerciseType,
            body.weight, body.height, body.bodyFat, body.bloodGlucose, body.bmr,
            sleep.sleepHours,
            nutrition.hydration,
            wellness.wellnessMinutes
        ]
        return values.allSatisfy { $0.isEmpty }
    }

    // MARK: - Nested payload objects
    //
    // Nested rather than top-level types so the names cannot collide with the existing
    // `WearableVitals` / `WearableActivity` / … response classes.

    struct Vitals: Encodable {
        var heartRate: String = ""            // bpm, integer
        var stressLevel: String = ""          // no HealthKit equivalent — always empty
        var restingHeartRate: String = ""     // bpm, integer
        var spo2: String = ""                 // percent, integer
        var respiratoryRate: String = ""      // breaths/min, integer
        var systolicPressure: String = ""     // mmHg, integer
        var diastolicPressure: String = ""    // mmHg, integer
        var hrv: String = ""                  // ms, integer
    }

    struct Activity: Encodable {
        var steps: String = ""                // integer
        var distance: String = ""             // km, 1 decimal
        var activeCalories: String = ""       // kcal, integer
        var totalCalories: String = ""        // active + basal, kcal, integer
        var exerciseMinutes: String = ""      // integer
        var exerciseType: String = ""         // e.g. "Walking", from the day's latest HKWorkout
    }

    struct Body: Encodable {
        var weight: String = ""               // kg, 1 decimal
        var height: String = ""               // cm, integer
        var bodyFat: String = ""              // percent, 1 decimal
        var bloodGlucose: String = ""         // mg/dL, integer
        var bmr: String = ""                  // kcal, integer (today's basal energy)
    }

    struct Sleep: Encodable {
        var sleepHours: String = ""           // hours, 1 decimal
    }

    struct Nutrition: Encodable {
        var hydration: String = ""            // litres, 1 decimal
    }

    struct Wellness: Encodable {
        var wellnessMinutes: String = ""      // mindful minutes today, integer
    }
}

/// Turns a HealthKit number into the string the API expects.
///
/// Two problems this exists to prevent:
///
/// 1. **Locale.** String interpolation and `String(format:)` both follow the device locale, so a
///    phone set to a comma-decimal locale would send `"6,7"` for distance. The backend then
///    either rejects the row or silently reads 6. The formatter is pinned to `en_US_POSIX` and
///    grouping is off, so 8542 steps is `"8542"` and never `"8,542"`.
/// 2. **Fabricated zeros.** `nil` in gives `""` out — never `"0"`.
///
/// A fresh `NumberFormatter` per call is intentional. `NumberFormatter` is not safe to mutate
/// from two threads, and a background wake-up can overlap a foreground sync; at roughly twenty
/// values every six hours the allocation cost is irrelevant next to that risk.
enum WearableValueFormatter {

    static func string(_ value: Double?, decimals: Int) -> String {
        guard let value = value, value.isFinite else { return "" }

        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals

        return formatter.string(from: NSNumber(value: value)) ?? ""
    }

    /// Whole numbers: heart rate, steps, calories, pressures, HRV, glucose, height, BMR, minutes.
    static func integer(_ value: Double?) -> String {
        string(value, decimals: 0)
    }

    /// One decimal: distance, weight, body fat, sleep hours, hydration.
    static func oneDecimal(_ value: Double?) -> String {
        string(value, decimals: 1)
    }
}
