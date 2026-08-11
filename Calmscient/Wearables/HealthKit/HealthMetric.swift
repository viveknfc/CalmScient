//
//  HealthMetric.swift
//  Calmscient
//
//  Catalog of the 20 health metrics shown on the Health Metrics screen,
//  grouped into 6 categories, with the HealthKit mapping for each.
//
//  11 August 2026
//

import Foundation
import HealthKit
import SwiftUI

/// The six categories the metrics are grouped under (matches the design).
enum HealthCategory: String, CaseIterable, Identifiable {
    case vitals
    case activity
    case sleep
    case body
    case nutrition
    case wellness

    var id: String { rawValue }

    var title: String {
        switch self {
        case .vitals:    return "Vitals"
        case .activity:  return "Activity"
        case .sleep:     return "Sleep"
        case .body:      return "Body"
        case .nutrition: return "Nutrition"
        case .wellness:  return "Wellness"
        }
    }

    /// Emoji shown next to the section header.
    var emoji: String {
        switch self {
        case .vitals:    return "🩺"
        case .activity:  return "🏃"
        case .sleep:     return "😴"
        case .body:      return "⚖️"
        case .nutrition: return "🥗"
        case .wellness:  return "🧘"
        }
    }
}

/// How a metric's samples are aggregated over a time bucket.
enum MetricAggregation {
    case cumulativeSum        // steps, calories, distance, water, exercise minutes
    case discreteAverage      // heart rate, spo2, glucose, respiratory rate, HRV
    case mostRecent           // weight, height, body fat
    case categoryDuration     // sleep, mindful minutes (hours/minutes asleep or mindful)
}

/// The 20 metrics from the design.
enum HealthMetricType: String, CaseIterable, Identifiable {
    // Vitals
    case heartRate
    case oxygenSaturation
    case stress
    case restingHeartRate
    case respiratoryRate
    case bloodPressure
    case heartRateVariability
    // Activity
    case exerciseMinutes
    case steps
    case calories
    case activeCalories
    case distance
    // Sleep
    case sleep
    // Body
    case weight
    case height
    case bodyFat
    case bloodGlucose
    case basalMetabolicRate
    // Nutrition
    case hydration
    // Wellness
    case wellness

    var id: String { rawValue }

    var category: HealthCategory {
        switch self {
        case .heartRate, .oxygenSaturation, .stress, .restingHeartRate,
             .respiratoryRate, .bloodPressure, .heartRateVariability:
            return .vitals
        case .exerciseMinutes, .steps, .calories, .activeCalories, .distance:
            return .activity
        case .sleep:
            return .sleep
        case .weight, .height, .bodyFat, .bloodGlucose, .basalMetabolicRate:
            return .body
        case .hydration:
            return .nutrition
        case .wellness:
            return .wellness
        }
    }

    var title: String {
        switch self {
        case .heartRate:            return "Heart Rate"
        case .oxygenSaturation:     return "SpO₂"
        case .stress:               return "Stress"
        case .restingHeartRate:     return "Resting HR"
        case .respiratoryRate:      return "Respiratory Rate"
        case .bloodPressure:        return "Blood Pressure"
        case .heartRateVariability: return "Heart Rate Variability"
        case .exerciseMinutes:      return "Exercise"
        case .steps:                return "Steps"
        case .calories:             return "Calories"
        case .activeCalories:       return "Active Calories"
        case .distance:             return "Distance"
        case .sleep:                return "Sleep"
        case .weight:               return "Weight"
        case .height:               return "Height"
        case .bodyFat:              return "Body Fat"
        case .bloodGlucose:         return "Blood Glucose"
        case .basalMetabolicRate:   return "BMR"
        case .hydration:            return "Hydration"
        case .wellness:             return "Wellness"
        }
    }

    /// SF Symbol shown at the leading edge of each row.
    var systemImage: String {
        switch self {
        case .heartRate:            return "heart.fill"
        case .oxygenSaturation:     return "drop.fill"
        case .stress:               return "brain.head.profile"
        case .restingHeartRate:     return "heart"
        case .respiratoryRate:      return "lungs.fill"
        case .bloodPressure:        return "stethoscope"
        case .heartRateVariability: return "waveform.path.ecg"
        case .exerciseMinutes:      return "figure.run"
        case .steps:                return "figure.walk"
        case .calories:             return "flame.fill"
        case .activeCalories:       return "flame"
        case .distance:             return "location.fill"
        case .sleep:                return "moon.fill"
        case .weight:               return "scalemass.fill"
        case .height:               return "ruler.fill"
        case .bodyFat:              return "percent"
        case .bloodGlucose:         return "drop.triangle.fill"
        case .basalMetabolicRate:   return "bolt.heart.fill"
        case .hydration:            return "waterbottle.fill"
        case .wellness:             return "figure.mind.and.body"
        }
    }

    /// Tint used for the row icon.
    var tint: Color {
        switch category {
        case .vitals:    return .red
        case .activity:  return .orange
        case .sleep:     return .indigo
        case .body:      return .teal
        case .nutrition: return .blue
        case .wellness:  return .purple
        }
    }

    /// Unit label appended after the value (e.g. "bpm", "steps").
    var unit: String {
        switch self {
        case .heartRate, .restingHeartRate: return "bpm"
        case .oxygenSaturation, .bodyFat:   return "%"
        case .stress:                       return "score"
        case .respiratoryRate:              return "breaths/min"
        case .bloodPressure:                return "mmHg"
        case .heartRateVariability:         return "ms"
        case .exerciseMinutes, .wellness:   return "min"
        case .steps:                        return "steps"
        case .calories, .activeCalories, .basalMetabolicRate: return "kcal"
        case .distance:                     return "km"
        case .sleep:                        return "hrs"
        case .weight:                       return "kg"
        case .height:                       return "cm"
        case .bloodGlucose:                 return "mg/dL"
        case .hydration:                    return "L"
        }
    }

    var aggregation: MetricAggregation {
        switch self {
        case .steps, .calories, .activeCalories, .distance,
             .exerciseMinutes, .basalMetabolicRate, .hydration:
            return .cumulativeSum
        case .heartRate, .oxygenSaturation, .restingHeartRate,
             .respiratoryRate, .heartRateVariability, .bloodGlucose:
            return .discreteAverage
        case .weight, .height, .bodyFat:
            return .mostRecent
        case .sleep, .wellness:
            return .categoryDuration
        case .stress, .bloodPressure:
            // Handled specially / not backed by a single HK quantity.
            return .discreteAverage
        }
    }

    /// Number of fraction digits to display for the value.
    var fractionDigits: Int {
        switch self {
        case .steps, .heartRate, .restingHeartRate, .stress,
             .calories, .activeCalories, .basalMetabolicRate, .exerciseMinutes, .wellness:
            return 0
        case .distance, .weight, .height, .sleep, .respiratoryRate,
             .heartRateVariability, .hydration, .bloodGlucose, .oxygenSaturation, .bodyFat:
            return 1
        case .bloodPressure:
            return 0
        }
    }

    // MARK: - HealthKit mapping

    /// The HealthKit quantity type backing this metric (nil for `stress`,
    /// category metrics, and blood pressure which uses two types).
    var quantityTypeIdentifier: HKQuantityTypeIdentifier? {
        switch self {
        case .heartRate:            return .heartRate
        case .oxygenSaturation:     return .oxygenSaturation
        case .restingHeartRate:     return .restingHeartRate
        case .respiratoryRate:      return .respiratoryRate
        case .heartRateVariability: return .heartRateVariabilitySDNN
        case .exerciseMinutes:      return .appleExerciseTime
        case .steps:                return .stepCount
        case .calories, .activeCalories: return .activeEnergyBurned
        case .distance:             return .distanceWalkingRunning
        case .weight:               return .bodyMass
        case .height:               return .height
        case .bodyFat:              return .bodyFatPercentage
        case .bloodGlucose:         return .bloodGlucose
        case .basalMetabolicRate:   return .basalEnergyBurned
        case .hydration:            return .dietaryWater
        case .stress, .bloodPressure, .sleep, .wellness:
            return nil
        }
    }

    /// The HealthKit unit the value is read in.
    var hkUnit: HKUnit {
        switch self {
        case .heartRate, .restingHeartRate, .respiratoryRate:
            return HKUnit.count().unitDivided(by: .minute())
        case .oxygenSaturation, .bodyFat:
            return HKUnit.percent()
        case .heartRateVariability:
            return HKUnit.secondUnit(with: .milli)
        case .steps:
            return HKUnit.count()
        case .calories, .activeCalories, .basalMetabolicRate:
            return HKUnit.kilocalorie()
        case .distance:
            return HKUnit.meterUnit(with: .kilo)
        case .weight:
            return HKUnit.gramUnit(with: .kilo)
        case .height:
            return HKUnit.meterUnit(with: .centi)
        case .bloodGlucose:
            return HKUnit(from: "mg/dL")
        case .hydration:
            return HKUnit.liter()
        default:
            return HKUnit.count()
        }
    }

    /// Some units need scaling from the raw HK value (percent → 0…100).
    func displayValue(fromHK value: Double) -> Double {
        switch self {
        case .oxygenSaturation, .bodyFat:
            return value * 100.0
        default:
            return value
        }
    }

    /// Metrics with no HealthKit source (shown as "--").
    var isHealthKitBacked: Bool { self != .stress }
}

/// A single point in a metric's trend series.
struct MetricPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

/// The time windows offered on the detail screen.
enum TrendRange: String, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"

    var id: String { rawValue }
    var title: String { rawValue }
}
