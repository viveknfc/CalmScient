//
//  WearableHealthSchema.swift
//  Calmscient
//
//  Cross-platform wearable health schema shared by the iOS (HealthKit) and
//  Android (Health Connect) clients and the backend.
//
//  The JSON keys below are the SINGLE canonical contract both platforms
//  serialize to and parse from. Android already writes these keys, so iOS maps
//  its HealthKit `HealthMetricType` catalog onto the exact same keys — one
//  parser reads either platform's payload, and one serializer produces a payload
//  Android's backend accepts unchanged.
//
//  Wire format notes (matched to the backend response):
//    • Numbers are serialized as 4-decimal strings, e.g. "72.0000".
//    • A whole section (vitals/activity/…) is `null` when a day has no data.
//    • `timestamp` is epoch-millis as a string; `date` is "yyyy-MM-dd".
//
//  12 August 2026
//

import Foundation

// MARK: - Wire value

/// A decimal that travels as a 4-dp string ("72.0000") but tolerates a raw JSON
/// number too. Stores a `Double`; always encodes back as `"%.4f"` so an
/// iOS-produced payload is byte-compatible with the Android/backend format.
struct WearableDecimal: Codable, Equatable {
    let value: Double

    init(_ value: Double) { self.value = value }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self), let parsed = Double(string) {
            value = parsed
        } else {
            value = try container.decode(Double.self)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(String(format: "%.4f", value))
    }
}

// MARK: - Top-level response

/// `GET` wearable-health response: a status envelope plus the day payload.
///
/// The backend returns `data` as an **array** for a date range and as a **single
/// object** for one date, so decoding tolerates both and always exposes `days`.
struct WearableHealthResponse: Codable {
    let statusResponse: ResponseDetails
    let days: [WearableHealthDay]

    enum CodingKeys: String, CodingKey {
        case statusResponse
        case data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        statusResponse = try container.decode(ResponseDetails.self, forKey: .statusResponse)
        if let array = try? container.decode([WearableHealthDay].self, forKey: .data) {
            days = array
        } else if let single = try container.decodeIfPresent(WearableHealthDay.self, forKey: .data) {
            days = [single]
        } else {
            days = []
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(statusResponse, forKey: .statusResponse)
        try container.encode(days, forKey: .data)
    }

    /// The best day to display: the one matching `date` if given, else the most
    /// recent day that actually carries data.
    func day(matching date: String?) -> WearableHealthDay? {
        if let date, let match = days.first(where: { $0.date == date }) { return match }
        return days.last(where: { !$0.isEmpty }) ?? days.last
    }
}

/// One day's cross-platform health snapshot. Every section is optional so both
/// "empty day" (`null` sections) and partial payloads round-trip cleanly.
struct WearableHealthDay: Codable {
    var patientId: Int?
    var date: String?
    var timestamp: String?
    var sourceDevice: String?
    var vitals: WearableVitals?
    var activity: WearableActivity?
    var body: WearableBody?
    var sleep: WearableSleep?
    var nutrition: WearableNutrition?
    var wellness: WearableWellness?

    /// True when no section carries a value (an "empty" day from the backend).
    var isEmpty: Bool {
        (vitals?.isEmpty ?? true) && (activity?.isEmpty ?? true) &&
        (body?.isEmpty ?? true) && (sleep?.isEmpty ?? true) &&
        (nutrition?.isEmpty ?? true) && (wellness?.isEmpty ?? true)
    }
}

// MARK: - Sections (Android/Health Connect canonical keys)

struct WearableVitals: Codable {
    var heartRate: WearableDecimal?
    var stressLevel: WearableDecimal?
    var restingHeartRate: WearableDecimal?
    var spo2: WearableDecimal?
    var respiratoryRate: WearableDecimal?
    var systolicPressure: WearableDecimal?
    var diastolicPressure: WearableDecimal?
    var hrv: WearableDecimal?

    var isEmpty: Bool {
        heartRate == nil && stressLevel == nil && restingHeartRate == nil &&
        spo2 == nil && respiratoryRate == nil && systolicPressure == nil &&
        diastolicPressure == nil && hrv == nil
    }
}

struct WearableActivity: Codable {
    var steps: WearableDecimal?
    var distance: WearableDecimal?
    var activeCalories: WearableDecimal?
    var totalCalories: WearableDecimal?
    var exerciseMinutes: WearableDecimal?
    var exerciseType: String?

    var isEmpty: Bool {
        steps == nil && distance == nil && activeCalories == nil &&
        totalCalories == nil && exerciseMinutes == nil && exerciseType == nil
    }
}

struct WearableBody: Codable {
    var weight: WearableDecimal?
    var height: WearableDecimal?
    var bodyFat: WearableDecimal?
    var bloodGlucose: WearableDecimal?
    var bmr: WearableDecimal?

    var isEmpty: Bool {
        weight == nil && height == nil && bodyFat == nil &&
        bloodGlucose == nil && bmr == nil
    }
}

struct WearableSleep: Codable {
    var sleepHours: WearableDecimal?
    var isEmpty: Bool { sleepHours == nil }
}

struct WearableNutrition: Codable {
    var hydration: WearableDecimal?
    var isEmpty: Bool { hydration == nil }
}

struct WearableWellness: Codable {
    var wellnessMinutes: WearableDecimal?
    var isEmpty: Bool { wellnessMinutes == nil }
}

// MARK: - Compatibility contract (iOS metric ↔ canonical key)

extension WearableHealthDay {

    /// The numeric value for an iOS metric read from the canonical (Android)
    /// keys, or `nil` when the day carries no value for it. Blood pressure
    /// returns the systolic component; use `displayString(for:)` for "120/80".
    func value(for metric: HealthMetricType) -> Double? {
        switch metric {
        case .heartRate:            return vitals?.heartRate?.value
        case .oxygenSaturation:     return vitals?.spo2?.value
        case .stress:               return vitals?.stressLevel?.value
        case .restingHeartRate:     return vitals?.restingHeartRate?.value
        case .respiratoryRate:      return vitals?.respiratoryRate?.value
        case .heartRateVariability: return vitals?.hrv?.value
        case .bloodPressure:        return vitals?.systolicPressure?.value
        case .exerciseMinutes:      return activity?.exerciseMinutes?.value
        case .steps:                return activity?.steps?.value
        case .calories:             return activity?.totalCalories?.value
        case .activeCalories:       return activity?.activeCalories?.value
        case .distance:             return activity?.distance?.value
        case .sleep:                return sleep?.sleepHours?.value
        case .weight:               return body?.weight?.value
        case .height:               return body?.height?.value
        case .bodyFat:              return body?.bodyFat?.value
        case .bloodGlucose:         return body?.bloodGlucose?.value
        case .basalMetabolicRate:   return body?.bmr?.value
        case .hydration:            return nutrition?.hydration?.value
        case .wellness:             return wellness?.wellnessMinutes?.value
        }
    }

    /// Row-ready display string honoring each metric's fraction digits and the
    /// special "systolic/diastolic" rendering for blood pressure.
    func displayString(for metric: HealthMetricType) -> String? {
        if metric == .bloodPressure {
            guard let systolic = vitals?.systolicPressure?.value,
                  let diastolic = vitals?.diastolicPressure?.value else { return nil }
            return "\(Int(systolic))/\(Int(diastolic))"
        }
        guard let value = value(for: metric) else { return nil }
        return String(format: "%.\(metric.fractionDigits)f", value)
    }

    /// Assembles a canonical day from iOS metric values (already display-scaled),
    /// dropping any section that has no data so the payload mirrors Android's
    /// `null`-section shape.
    static func make(patientId: Int,
                     date: Date,
                     sourceDevice: String,
                     values: [HealthMetricType: Double],
                     bloodPressure: (systolic: Double, diastolic: Double)?,
                     exerciseType: String?) -> WearableHealthDay {

        func decimal(_ metric: HealthMetricType) -> WearableDecimal? {
            values[metric].map(WearableDecimal.init)
        }

        var vitals = WearableVitals()
        vitals.heartRate = decimal(.heartRate)
        vitals.stressLevel = decimal(.stress)
        vitals.restingHeartRate = decimal(.restingHeartRate)
        vitals.spo2 = decimal(.oxygenSaturation)
        vitals.respiratoryRate = decimal(.respiratoryRate)
        vitals.hrv = decimal(.heartRateVariability)
        if let bp = bloodPressure {
            vitals.systolicPressure = WearableDecimal(bp.systolic)
            vitals.diastolicPressure = WearableDecimal(bp.diastolic)
        }

        var activity = WearableActivity()
        activity.steps = decimal(.steps)
        activity.distance = decimal(.distance)
        activity.activeCalories = decimal(.activeCalories)
        activity.totalCalories = decimal(.calories)
        activity.exerciseMinutes = decimal(.exerciseMinutes)
        activity.exerciseType = exerciseType

        var body = WearableBody()
        body.weight = decimal(.weight)
        body.height = decimal(.height)
        body.bodyFat = decimal(.bodyFat)
        body.bloodGlucose = decimal(.bloodGlucose)
        body.bmr = decimal(.basalMetabolicRate)

        var sleep = WearableSleep()
        sleep.sleepHours = decimal(.sleep)

        var nutrition = WearableNutrition()
        nutrition.hydration = decimal(.hydration)

        var wellness = WearableWellness()
        wellness.wellnessMinutes = decimal(.wellness)

        let dayFormatter = WearableHealthDay.dayFormatter
        return WearableHealthDay(
            patientId: patientId,
            date: dayFormatter.string(from: date),
            timestamp: String(Int(date.timeIntervalSince1970 * 1000)),
            sourceDevice: sourceDevice,
            vitals: vitals.isEmpty ? nil : vitals,
            activity: activity.isEmpty ? nil : activity,
            body: body.isEmpty ? nil : body,
            sleep: sleep.isEmpty ? nil : sleep,
            nutrition: nutrition.isEmpty ? nil : nutrition,
            wellness: wellness.isEmpty ? nil : wellness
        )
    }

    /// "yyyy-MM-dd" in the device's current calendar, matching the backend.
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
