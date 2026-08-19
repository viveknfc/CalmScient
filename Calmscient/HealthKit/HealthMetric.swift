//
//  HealthMetric.swift
//  Calmscient
//
//  Created by NFC Solutions on 11/08/26.
//

import Foundation
import HealthKit

enum HealthMetricCategory: String, CaseIterable, Identifiable {
    case vitals      = "Vitals"
    case activity    = "Activity"
    case sleep       = "Sleep"
    case body        = "Body"
    case nutrition   = "Nutrition"
    case wellness    = "Wellness"

    var id: String { rawValue }
    var localizedTitle: String { rawValue.localized }
}

enum HealthAggregation {
    case cumulativeSum      // steps, calories, distance, water, exercise minutes
    case discreteAverage    // heart rate, SpO2, respiratory rate, glucose, HRV
    case discreteMostRecent // weight, height, body fat (latest sample in the bucket)
}

enum HealthMetricSource {
    /// A single HealthKit quantity type read directly.
    case healthKit(HKQuantityTypeIdentifier)
    /// Sleep uses a category type, not a quantity type.
    case sleepCategory
    /// Blood pressure is a correlation of systolic + diastolic.
    case bloodPressure
    /// No direct HK equivalent — Stress / BMR / Wellness. Value is produced by
    /// product logic (formula, HRV proxy, or backend), never a raw HK read.
    case derived(DerivedKind)
}

enum DerivedKind {
    case stress     // proxy from HRV or backend score
    case bmr        // Mifflin–St Jeor, or approximate from basalEnergyBurned
    case wellness   // mindful minutes / business definition
}

//MARK: - Health Metrics

struct HealthMetric: Identifiable, Equatable {
    let id: String                 // stable key sent to backend, e.g. "heart_rate"
    let category: HealthMetricCategory
    let titleKey: String           // localized via .localized
    let iconName: String           // your asset name (SF Symbol or xcassets)
    let unit: String               // display unit, e.g. "bpm"
    let hkUnit: HKUnit?            // HealthKit unit for reads (nil for derived/sleep)
    let aggregation: HealthAggregation
    let source: HealthMetricSource

    static func == (lhs: HealthMetric, rhs: HealthMetric) -> Bool { lhs.id == rhs.id }
}

// MARK: - The full catalog (17 HealthKit + 3 derived)

extension HealthMetric {

    static let all: [HealthMetric] = vitals + activity + sleep + body + nutrition + wellness

    static func metric(for id: String) -> HealthMetric? { all.first { $0.id == id } }
    static func metrics(in category: HealthMetricCategory) -> [HealthMetric] {
        all.filter { $0.category == category }
    }

    // ---- Vitals ----
    static let vitals: [HealthMetric] = [
        HealthMetric(id: "heart_rate", category: .vitals, titleKey: "Heart Rate",
                     iconName: "heart.fill", unit: "bpm",
                     hkUnit: HKUnit.count().unitDivided(by: .minute()),
                     aggregation: .discreteAverage, source: .healthKit(.heartRate)),

        HealthMetric(id: "spo2", category: .vitals, titleKey: "SpO2",
                     iconName: "drop.fill", unit: "%",
                     hkUnit: .percent(),
                     aggregation: .discreteAverage, source: .healthKit(.oxygenSaturation)),

        HealthMetric(id: "stress", category: .vitals, titleKey: "Stress",
                     iconName: "brain.head.profile", unit: "score",
                     hkUnit: nil,
                     aggregation: .discreteAverage, source: .derived(.stress)),

        HealthMetric(id: "resting_hr", category: .vitals, titleKey: "Resting HR",
                     iconName: "heart.circle", unit: "bpm",
                     hkUnit: HKUnit.count().unitDivided(by: .minute()),
                     aggregation: .discreteAverage, source: .healthKit(.restingHeartRate)),

        HealthMetric(id: "respiratory_rate", category: .vitals, titleKey: "Respiratory Rate",
                     iconName: "lungs.fill", unit: "breaths/min",
                     hkUnit: HKUnit.count().unitDivided(by: .minute()),
                     aggregation: .discreteAverage, source: .healthKit(.respiratoryRate)),

        HealthMetric(id: "blood_pressure", category: .vitals, titleKey: "Blood Pressure",
                     iconName: "stethoscope", unit: "mmHg",
                     hkUnit: .millimeterOfMercury(),
                     aggregation: .discreteAverage, source: .bloodPressure),

        HealthMetric(id: "hrv", category: .vitals, titleKey: "Heart Rate Variability",
                     iconName: "waveform.path.ecg", unit: "ms",
                     hkUnit: .secondUnit(with: .milli),
                     aggregation: .discreteAverage, source: .healthKit(.heartRateVariabilitySDNN)),
    ]

    // ---- Activity ----
    static let activity: [HealthMetric] = [
        HealthMetric(id: "exercise", category: .activity, titleKey: "Exercise",
                     iconName: "figure.run", unit: "min",
                     hkUnit: .minute(),
                     aggregation: .cumulativeSum, source: .healthKit(.appleExerciseTime)),

        HealthMetric(id: "steps", category: .activity, titleKey: "Steps",
                     iconName: "shoeprints.fill", unit: "steps",
                     hkUnit: .count(),
                     aggregation: .cumulativeSum, source: .healthKit(.stepCount)),

        HealthMetric(id: "active_calories", category: .activity, titleKey: "Active Calories",
                     iconName: "flame.fill", unit: "kcal",
                     hkUnit: .kilocalorie(),
                     aggregation: .cumulativeSum, source: .healthKit(.activeEnergyBurned)),

        HealthMetric(id: "distance", category: .activity, titleKey: "Distance",
                     iconName: "location.fill", unit: "km",
                     hkUnit: .meterUnit(with: .kilo),
                     aggregation: .cumulativeSum, source: .healthKit(.distanceWalkingRunning)),
        // NOTE: "Calories" (basal + active) is a composite — see HealthKitManager for how
        // to sum two types. Add it as a derived/composite entry if you want it as a row.
    ]

    // ---- Sleep ----
    static let sleep: [HealthMetric] = [
        HealthMetric(id: "sleep", category: .sleep, titleKey: "Sleep",
                     iconName: "moon.fill", unit: "hrs",
                     hkUnit: .hour(),
                     aggregation: .cumulativeSum, source: .sleepCategory),
    ]

    // ---- Body ----
    static let body: [HealthMetric] = [
        HealthMetric(id: "weight", category: .body, titleKey: "Weight",
                     iconName: "scalemass.fill", unit: "kg",
                     hkUnit: .gramUnit(with: .kilo),
                     aggregation: .discreteMostRecent, source: .healthKit(.bodyMass)),

        HealthMetric(id: "height", category: .body, titleKey: "Height",
                     iconName: "ruler.fill", unit: "cm",
                     hkUnit: .meterUnit(with: .centi),
                     aggregation: .discreteMostRecent, source: .healthKit(.height)),

        HealthMetric(id: "body_fat", category: .body, titleKey: "Body Fat",
                     iconName: "figure.arms.open", unit: "%",
                     hkUnit: .percent(),
                     aggregation: .discreteMostRecent, source: .healthKit(.bodyFatPercentage)),

        HealthMetric(id: "blood_glucose", category: .body, titleKey: "Blood Glucose",
                     iconName: "drop.triangle.fill", unit: "mg/dL",
                     hkUnit: HKUnit.gramUnit(with: .milli).unitDivided(by: .literUnit(with: .deci)),
                     aggregation: .discreteAverage, source: .healthKit(.bloodGlucose)),

        HealthMetric(id: "bmr", category: .body, titleKey: "BMR",
                     iconName: "flame.circle", unit: "kcal",
                     hkUnit: nil,
                     aggregation: .discreteMostRecent, source: .derived(.bmr)),
    ]

    // ---- Nutrition ----
    static let nutrition: [HealthMetric] = [
        HealthMetric(id: "hydration", category: .nutrition, titleKey: "Hydration",
                     iconName: "drop.fill", unit: "L",
                     hkUnit: .liter(),
                     aggregation: .cumulativeSum, source: .healthKit(.dietaryWater)),
    ]

    // ---- Wellness ----
    static let wellness: [HealthMetric] = [
        HealthMetric(id: "wellness", category: .wellness, titleKey: "Wellness",
                     iconName: "leaf.fill", unit: "min",
                     hkUnit: nil,
                     aggregation: .cumulativeSum, source: .derived(.wellness)),
    ]
}
