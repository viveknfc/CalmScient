//
//  WearableRangeDayPresentation.swift
//  Calmscient
//
//  Presentation models for the "Health Data" range list opened from the calendar
//  button on the Health Metrics screen.
//
//  A day card mirrors the dashboard look: a date header, then one block per
//  wearable category (Vitals / Activity / Sleep / Body / Nutrition / Wellness)
//  with a "label -> value" line for every field the backend returned.
//

import Foundation

// MARK: - Row

/// One "label -> value" line inside a category block, e.g. "Heart Rate" / "80 bpm".
struct WearableRangeValueRow: Identifiable, Equatable {
    let id: String
    let title: String
    let valueText: String
}

// MARK: - Category block

struct WearableRangeCategoryPresentation: Identifiable, Equatable {
    let id: String
    let title: String
    /// SF Symbol drawn beside the block title.
    let iconName: String
    let rows: [WearableRangeValueRow]
}

// MARK: - Day card

/// One day of the selected range.
///
/// `categories` is empty when the backend has no reading for that date — the card
/// then shows nothing but the date header, which is the agreed empty state.
struct WearableRangeDayPresentation: Identifiable, Equatable {
    let id: String            // "yyyy-MM-dd" — stable across reloads
    let dateHeader: String    // "8 Jul 2026"
    let categories: [WearableRangeCategoryPresentation]

    var isEmpty: Bool { categories.isEmpty }
}

// MARK: - Field catalog
//
// Deliberately independent from `HealthMetric.all`: that catalog drives the
// HealthKit rows and does not carry every field the wearable API returns
// (total calories, exercise type, …). Keeping this table local means the range
// list can render the full payload without touching the metric catalog.

private struct WearableRangeField {
    let id: String
    let titleKey: String
    let unit: String
    let read: (WearableData) -> String?
}

private struct WearableRangeCategoryDescriptor {
    let id: String
    let titleKey: String
    let iconName: String
    let fields: [WearableRangeField]
}

private enum WearableRangeCatalog {

    // Split one-category-per-property on purpose: a single 6-category literal with
    // ~20 closures inside is exactly the shape that trips the type-checker's
    // "unable to type-check in reasonable time" limit.

    static let categories: [WearableRangeCategoryDescriptor] = [
        vitals, activity, sleep, body, nutrition, wellness
    ]

    private static let vitals = WearableRangeCategoryDescriptor(
        id: "vitals", titleKey: "Vitals", iconName: "heart.fill",
        fields: [
            WearableRangeField(id: "heart_rate", titleKey: "Heart Rate", unit: "bpm",
                               read: { $0.vitals?.heartRate }),
            WearableRangeField(id: "spo2", titleKey: "SpO2", unit: "%",
                               read: { $0.vitals?.spo2 }),
            WearableRangeField(id: "stress", titleKey: "Stress", unit: "",
                               read: { $0.vitals?.stressLevel }),
            WearableRangeField(id: "resting_hr", titleKey: "Resting Heart Rate", unit: "bpm",
                               read: { $0.vitals?.restingHeartRate }),
            WearableRangeField(id: "respiratory_rate", titleKey: "Respiratory Rate", unit: "breaths/min",
                               read: { $0.vitals?.respiratoryRate }),
            WearableRangeField(id: "blood_pressure", titleKey: "Blood Pressure", unit: "mmHg",
                               read: { WearableRangeCatalog.bloodPressure($0) }),
            WearableRangeField(id: "hrv", titleKey: "Heart Rate Variability (HRV)", unit: "ms",
                               read: { $0.vitals?.hrv }),
        ])

    private static let activity = WearableRangeCategoryDescriptor(
        id: "activity", titleKey: "Activity", iconName: "figure.walk",
        fields: [
            WearableRangeField(id: "steps", titleKey: "Steps", unit: "",
                               read: { $0.activity?.steps }),
            WearableRangeField(id: "distance", titleKey: "Distance", unit: "km",
                               read: { $0.activity?.distance }),
            WearableRangeField(id: "total_calories", titleKey: "Calories", unit: "kcal",
                               read: { $0.activity?.totalCalories }),
            WearableRangeField(id: "active_calories", titleKey: "Active Calories", unit: "kcal",
                               read: { $0.activity?.activeCalories }),
            WearableRangeField(id: "exercise", titleKey: "Exercise", unit: "min",
                               read: { $0.activity?.exerciseMinutes }),
            WearableRangeField(id: "exercise_type", titleKey: "Exercise Type", unit: "",
                               read: { $0.activity?.exerciseType }),
        ])

    private static let sleep = WearableRangeCategoryDescriptor(
        id: "sleep", titleKey: "Sleep", iconName: "moon.fill",
        fields: [
            WearableRangeField(id: "sleep_hours", titleKey: "Sleep Hours", unit: "hrs",
                               read: { $0.sleep?.sleepHours }),
        ])

    private static let body = WearableRangeCategoryDescriptor(
        id: "body", titleKey: "Body", iconName: "figure.stand",
        fields: [
            WearableRangeField(id: "weight", titleKey: "Weight", unit: "kg",
                               read: { $0.body?.weight }),
            WearableRangeField(id: "height", titleKey: "Height", unit: "cm",
                               read: { $0.body?.height }),
            WearableRangeField(id: "body_fat", titleKey: "Body Fat", unit: "%",
                               read: { $0.body?.bodyFat }),
            WearableRangeField(id: "blood_glucose", titleKey: "Blood Glucose", unit: "mg/dL",
                               read: { $0.body?.bloodGlucose }),
            WearableRangeField(id: "bmr", titleKey: "BMR", unit: "kcal",
                               read: { $0.body?.bmr }),
        ])

    private static let nutrition = WearableRangeCategoryDescriptor(
        id: "nutrition", titleKey: "Nutrition", iconName: "drop.fill",
        fields: [
            WearableRangeField(id: "hydration", titleKey: "Hydration", unit: "L",
                               read: { $0.nutrition?.hydration }),
        ])

    private static let wellness = WearableRangeCategoryDescriptor(
        id: "wellness", titleKey: "Wellness", iconName: "leaf.fill",
        fields: [
            WearableRangeField(id: "wellness_minutes", titleKey: "Wellness", unit: "min",
                               read: { $0.wellness?.wellnessMinutes }),
        ])

    /// Systolic + diastolic are two fields but one row: "113/95".
    private static func bloodPressure(_ data: WearableData) -> String? {
        guard let systolic = trimmed(data.vitals?.systolicPressure),
              let diastolic = trimmed(data.vitals?.diastolicPressure) else { return nil }
        return "\(systolic)/\(diastolic)"
    }

    static func trimmed(_ value: String?) -> String? {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty,
              value.lowercased() != "null" else { return nil }
        return value
    }
}

// MARK: - Builder

enum WearableRangeDayBuilder {

    /// Every date between `startDate` and `endDate` inclusive, oldest first, with the
    /// matching payload merged in. Dates the backend skipped still produce a card so
    /// the list reads as a continuous calendar.
    static func days(from startDate: Date,
                     to endDate: Date,
                     payload: [WearableData]) -> [WearableRangeDayPresentation] {

        var byDate: [String: WearableData] = [:]
        for entry in payload {
            guard let key = WearableRangeCatalog.trimmed(entry.date) else { continue }
            byDate[String(key.prefix(10))] = entry
        }

        return dateKeys(from: startDate, to: endDate).map { key in
            WearableRangeDayPresentation(
                id: key,
                dateHeader: headerLabel(from: key),
                categories: categories(for: byDate[key]))
        }
    }

    // MARK: - Categories

    private static func categories(for data: WearableData?) -> [WearableRangeCategoryPresentation] {
        guard let data else { return [] }

        return WearableRangeCatalog.categories.compactMap { descriptor in
            let rows: [WearableRangeValueRow] = descriptor.fields.compactMap { field in
                guard let raw = WearableRangeCatalog.trimmed(field.read(data)) else { return nil }
                return WearableRangeValueRow(
                    id: field.id,
                    title: field.titleKey.localized,
                    valueText: displayText(raw, unit: field.unit))
            }
            guard !rows.isEmpty else { return nil }
            return WearableRangeCategoryPresentation(
                id: descriptor.id,
                title: descriptor.titleKey.localized,
                iconName: descriptor.iconName,
                rows: rows)
        }
    }

    /// "7497" + "" -> "7,497" ; "80" + "bpm" -> "80 bpm".
    private static func displayText(_ raw: String, unit: String) -> String {
        let value = grouped(raw)
        guard !unit.isEmpty else { return value }
        return "\(value) \(unit)"
    }

    private static func grouped(_ raw: String) -> String {
        guard let number = Double(raw) else { return raw }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: number)) ?? raw
    }

    // MARK: - Dates

    private static let apiFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private static let headerFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()

    /// "yyyy-MM-dd" keys for every day of the range (capped so a stray selection
    /// can never build an unbounded list).
    static func dateKeys(from startDate: Date, to endDate: Date) -> [String] {
        let calendar = Calendar.current
        var cursor = calendar.startOfDay(for: min(startDate, endDate))
        let last = calendar.startOfDay(for: max(startDate, endDate))

        var keys: [String] = []
        while cursor <= last, keys.count < 400 {
            keys.append(apiFormatter.string(from: cursor))
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return keys
    }

    /// "2026-07-08" -> "8 Jul 2026" (falls back to the raw string).
    static func headerLabel(from apiDate: String) -> String {
        guard let date = apiFormatter.date(from: apiDate) else { return apiDate }
        return headerFormatter.string(from: date)
    }
}
