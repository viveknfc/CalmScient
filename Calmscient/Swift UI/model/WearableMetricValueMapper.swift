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

/// Anything that carries the six wearable category objects.
///
/// A single day (`WearableData`) and one bucket of period averages
/// (`WearableAverageBucket`) hold identical category payloads under identical keys, so the
/// metric-to-field mapping below is written once against this protocol rather than twice
/// against the two response types — the alternative drifts the moment a field is added.
protocol WearableMetricContainer {
    var vitals: WearableVitals? { get }
    var activity: WearableActivity? { get }
    var body: WearableBody? { get }
    var sleep: WearableSleep? { get }
    var nutrition: WearableNutrition? { get }
    var wellness: WearableWellness? { get }
}

extension WearableData: WearableMetricContainer {}
extension WearableAverageBucket: WearableMetricContainer {}

enum WearableMetricValueMapper {

    /// Returns the display value for `metric` from a day's wearable payload.
    /// Returns "--" when the field is missing/empty.
    static func value(for metric: HealthMetric, in data: WearableMetricContainer?) -> String {
        guard let data else { return "--" }
        let unit = metric.unit

        // Blood pressure is a composite of two fields.
        if metric.id == "blood_pressure" {
            if let s = nonEmpty(data.vitals?.systolicPressure),
               let d = nonEmpty(data.vitals?.diastolicPressure) {
                return "\(display(s))/\(display(d)) \(unit)"
            }
            return "--"
        }

        guard let value = number(for: metric, in: data) else { return "--" }
        return "\(formatted(value, metric: metric)) \(unit)"
    }

    /// The same field as `value(for:in:)` but numeric, for charting.
    ///
    /// `nil` means "no reading", which the chart draws as a gap rather than as a zero —
    /// the two are very different claims about a month of someone's heart rate. Blood
    /// pressure charts its systolic half, since a single bar can only carry one number.
    static func number(for metric: HealthMetric, in data: WearableMetricContainer?) -> Double? {
        guard let data else { return nil }
        let raw = metric.id == "blood_pressure"
            ? data.vitals?.systolicPressure
            : rawValue(for: metric, in: data)
        guard let text = nonEmpty(raw), let value = Double(text) else { return nil }
        return value
    }

    /// Averages arrive with four decimals ("79.7917"). Whole-number metrics read better
    /// rounded, and the rest keep one decimal.
    static func formatted(_ value: Double, metric: HealthMetric) -> String {
        switch metric.unit {
        case "bpm", "steps", "min", "kcal", "score", "%", "ms", "mg/dL", "mmHg", "breaths/min":
            return String(Int(value.rounded()))
        default:
            return String(format: "%.1f", value)
        }
    }

    /// Trims an already-formatted server string for the composite BP display.
    private static func display(_ raw: String) -> String {
        guard let value = Double(raw) else { return raw }
        return String(Int(value.rounded()))
    }

    private static func rawValue(for metric: HealthMetric, in data: WearableMetricContainer) -> String? {
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
        return raw
    }

    private static func nonEmpty(_ s: String?) -> String? {
        guard let s = s?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty else { return nil }
        return s
    }
}
