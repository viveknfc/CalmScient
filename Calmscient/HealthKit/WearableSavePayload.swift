//
//  WearableSavePayload.swift
//  Calmscient
//
//  Created by NFC Solutions on 19/08/26.
//

import Foundation

/// Request body for `POST patients/api/v1/health/wearable-data`.
///
/// Deliberately *not* the same shape as `WearableData` (the GET response): the read API
/// returns every value as a `String` under names like `systolicPressure`, while the write
/// API takes numbers under `bloodPressureSystolic`. Reusing one model for both would mean
/// one of the two endpoints silently receiving the wrong keys, so the write side gets its
/// own type whose property names are exactly the JSON keys the server expects.
///
/// Every field is optional and the synthesized encoder drops `nil`, so a metric the phone
/// has no reading for is absent from the body rather than sent as 0 — the server can then
/// tell "not measured" from "measured as zero". Category objects are dropped whole when
/// they hold nothing (see `Builder.nilIfEmpty`).
struct WearableSavePayload: Encodable {
    let patientId: Int
    let timestamp: String          // ISO-8601 UTC, e.g. "2026-08-19T16:30:00Z"
    let sourceDevice: String
    let vitals: Vitals?
    let activity: Activity?
    let body: Body?
    let sleep: Sleep?
    let nutrition: Nutrition?
    let wellness: Wellness?

    struct Vitals: Encodable {
        var heartRate: Int?
        var spo2: Double?
        var stress: Int?
        var restingHeartRate: Int?
        var respiratoryRate: Double?
        var bloodPressureSystolic: Int?
        var bloodPressureDiastolic: Int?
        var bodyTemperature: Double?

        var isEmpty: Bool {
            heartRate == nil && spo2 == nil && stress == nil && restingHeartRate == nil
                && respiratoryRate == nil && bloodPressureSystolic == nil
                && bloodPressureDiastolic == nil && bodyTemperature == nil
        }
    }

    struct Activity: Encodable {
        var steps: Int?
        var distanceKm: Double?
        var caloriesBurned: Int?
        var activeMinutes: Int?
        var floorsClimbed: Int?

        var isEmpty: Bool {
            steps == nil && distanceKm == nil && caloriesBurned == nil
                && activeMinutes == nil && floorsClimbed == nil
        }
    }

    struct Body: Encodable {
        var weightKg: Double?
        var heightCm: Double?
        var bodyFatPercentage: Double?
        var bmi: Double?
        var muscleMassKg: Double?
        var waterPercentage: Double?

        var isEmpty: Bool {
            weightKg == nil && heightCm == nil && bodyFatPercentage == nil
                && bmi == nil && muscleMassKg == nil && waterPercentage == nil
        }
    }

    struct Sleep: Encodable {
        var totalSleepHours: Double?
        var deepSleepHours: Double?
        var lightSleepHours: Double?
        var remSleepHours: Double?
        var sleepScore: Int?

        var isEmpty: Bool {
            totalSleepHours == nil && deepSleepHours == nil && lightSleepHours == nil
                && remSleepHours == nil && sleepScore == nil
        }
    }

    struct Nutrition: Encodable {
        var caloriesConsumed: Int?
        var waterIntakeLiters: Double?
        var proteinGrams: Int?
        var carbohydratesGrams: Int?
        var fatGrams: Int?

        var isEmpty: Bool {
            caloriesConsumed == nil && waterIntakeLiters == nil && proteinGrams == nil
                && carbohydratesGrams == nil && fatGrams == nil
        }
    }

    struct Wellness: Encodable {
        var mood: String?
        var energyLevel: Int?
        var stressLevel: Int?
        var recoveryScore: Int?

        var isEmpty: Bool {
            mood == nil && energyLevel == nil && stressLevel == nil && recoveryScore == nil
        }
    }

    /// True when there is nothing worth sending — every category came back empty.
    /// Used to skip the call entirely on a device with no health data (Simulator, or a
    /// phone whose owner denied every read), instead of POSTing a bare patient id.
    var hasNoReadings: Bool {
        vitals == nil && activity == nil && body == nil
            && sleep == nil && nutrition == nil && wellness == nil
    }

    /// The body as a JSON dictionary, because `APIService.getRequestWithToken` serializes
    /// `[String: Any]` rather than taking `Data`. Round-tripping through `JSONEncoder`
    /// keeps the `nil`-dropping behaviour instead of hand-building the dictionary.
    func jsonObject() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "WearableSavePayload", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Payload did not encode to a JSON object."])
        }
        return dict
    }
}
