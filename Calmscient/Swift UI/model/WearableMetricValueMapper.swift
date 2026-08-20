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

    // MARK: - Single day (unchanged behaviour)

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

        guard let value = nonEmpty(raw(for: metric.id,
                                      vitals: data.vitals,
                                      activity: data.activity,
                                      body: data.body,
                                      sleep: data.sleep,
                                      nutrition: data.nutrition,
                                      wellness: data.wellness)) else { return "--" }
        return "\(value) \(unit)"
    }

    // MARK: - Period averages (chart)

    /// Numeric series for one average bucket. Empty when the bucket carries no
    /// value for this metric (chart draws a gap, never a zero).
    ///
    /// Blood pressure yields two series (systolic + diastolic); every other
    /// metric yields a single `primary` series.
    static func seriesValues(for metric: HealthMetric,
                             in bucket: WearableAverageBucket?) -> [WearableMetricSeriesValue] {
        guard let bucket, !bucket.isEmptyBucket else { return [] }

        if metric.id == "blood_pressure" {
            var values: [WearableMetricSeriesValue] = []
            if let systolic = number(bucket.vitals?.systolicPressure) {
                values.append(WearableMetricSeriesValue(seriesKey: .systolic, value: systolic))
            }
            if let diastolic = number(bucket.vitals?.diastolicPressure) {
                values.append(WearableMetricSeriesValue(seriesKey: .diastolic, value: diastolic))
            }
            return values
        }

        guard let value = number(raw(for: metric.id,
                                     vitals: bucket.vitals,
                                     activity: bucket.activity,
                                     body: bucket.body,
                                     sleep: bucket.sleep,
                                     nutrition: bucket.nutrition,
                                     wellness: bucket.wellness)) else { return [] }
        return [WearableMetricSeriesValue(seriesKey: .primary, value: value)]
    }

    /// "79.8 bpm" / "7,280 steps" / "7.3 hrs". Large values lose the decimals
    /// because a fractional step or calorie reads as noise.
    static func formatted(_ value: Double, for metric: HealthMetric, includeUnit: Bool = true) -> String {
        let text = formattedNumber(value)
        guard includeUnit, !metric.unit.isEmpty else { return text }
        return "\(text) \(metric.unit)"
    }

    /// Number only, no unit — used for axis labels.
    static func formattedNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        let fractionDigits = abs(value) >= 100 ? 0 : 1
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = fractionDigits
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.\(fractionDigits)f", value)
    }

    // MARK: - Field lookup

    /// Single place that knows which payload field backs each metric id.
    private static func raw(for metricId: String,
                            vitals: WearableVitals?,
                            activity: WearableActivity?,
                            body: WearableBody?,
                            sleep: WearableSleep?,
                            nutrition: WearableNutrition?,
                            wellness: WearableWellness?) -> String? {
        switch metricId {
        // Vitals
        case "heart_rate":        return vitals?.heartRate
        case "spo2":              return vitals?.spo2
        case "stress":            return vitals?.stressLevel
        case "resting_hr":        return vitals?.restingHeartRate
        case "respiratory_rate":  return vitals?.respiratoryRate
        case "hrv":               return vitals?.hrv
        case "blood_pressure":    return vitals?.systolicPressure
        // Activity
        case "exercise":          return activity?.exerciseMinutes
        case "steps":             return activity?.steps
        case "active_calories":   return activity?.activeCalories
        case "distance":          return activity?.distance
        // Sleep
        case "sleep":             return sleep?.sleepHours
        // Body
        case "weight":            return body?.weight
        case "height":            return body?.height
        case "body_fat":          return body?.bodyFat
        case "blood_glucose":     return body?.bloodGlucose
        case "bmr":               return body?.bmr
        // Nutrition
        case "hydration":         return nutrition?.hydration
        // Wellness
        case "wellness":          return wellness?.wellnessMinutes
        default:                  return nil
        }
    }

    private static func nonEmpty(_ s: String?) -> String? {
        guard let s = s?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty else { return nil }
        return s
    }

    /// Backend sends averages as strings ("79.7917"). Zero values are kept (a real
    /// 0 steps day is data); empty, unparseable and non-finite values ("NaN",
    /// "Infinity" from a divide-by-zero average) are dropped so they can never
    /// reach the chart's scale domain.
    private static func number(_ s: String?) -> Double? {
        guard let text = nonEmpty(s), let value = Double(text), value.isFinite else { return nil }
        return value
    }
}
