//
//  WearableMetricValueMapper.swift
//  Calmscient
//
//  Created by NFC Solutions on 12/08/26.
//

import Foundation

/// One row in the detail list: a date header + the metric value for that date.
struct HealthMetricDayValue: Identifiable, Equatable {
    let id = UUID()
    let dateHeader: String   // "19 Jul 2026"
    let valueText: String    // "72 bpm" / "120/80 mmHg" / "--"
}

enum WearableMetricValueMapper {

    /// Returns the display value for `metric` from a day's wearable payload.
    /// Returns "--" when the field is missing/empty.
    static func value(for metric: HealthMetric, in data: WearableData?) -> String {
        guard let data else { return "--" }
        let unit = metric.unit

        // Blood pressure is a composite of two fields.
        if metric.id == "blood_pressure" {
            if let s = nonEmpty(data.vitals?.systolicPressure),
               let d = nonEmpty(data.vitals?.diastolicPressure) {
                return "\(s)/\(d) \(unit)"
            }
            return "--"
        }

        let raw: String?
        switch metric.id {
        // Vitals
        case "heart_rate":        raw = data.vitals?.heartRate
        case "spo2":              raw = data.vitals?.spo2
        case "stress":            raw = data.vitals?.stressLevel
        case "resting_hr":        raw = data.vitals?.restingHeartRate
        case "respiratory_rate":  raw = data.vitals?.respiratoryRate
        case "hrv":               raw = data.vitals?.hrv
        // Activity
        case "exercise":          raw = data.activity?.exerciseMinutes
        case "steps":             raw = data.activity?.steps
        case "active_calories":   raw = data.activity?.activeCalories
        case "distance":          raw = data.activity?.distance
        // Sleep
        case "sleep":             raw = data.sleep?.sleepHours
        // Body
        case "weight":            raw = data.body?.weight
        case "height":            raw = data.body?.height
        case "body_fat":          raw = data.body?.bodyFat
        case "blood_glucose":     raw = data.body?.bloodGlucose
        case "bmr":               raw = data.body?.bmr
        // Nutrition
        case "hydration":         raw = data.nutrition?.hydration
        // Wellness
        case "wellness":          raw = data.wellness?.wellnessMinutes
        default:                  raw = nil
        }

        guard let value = nonEmpty(raw) else { return "--" }
        return "\(value) \(unit)"
    }

    private static func nonEmpty(_ s: String?) -> String? {
        guard let s = s?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty else { return nil }
        return s
    }
}
