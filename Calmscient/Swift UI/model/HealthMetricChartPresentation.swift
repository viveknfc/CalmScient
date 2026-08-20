//
//  HealthMetricChartPresentation.swift
//  Calmscient
//
//  View data for the health metric averages chart (period tabs + chart + insights).
//
//  Created by NFC Solutions on 19/08/26.
//

import Foundation

/// Which line/bar a value belongs to. Only blood pressure uses more than one.
enum HealthMetricChartSeriesKey: String, Equatable, Hashable {
    case primary
    case systolic
    case diastolic

    /// Legend title. `nil` for single-series metrics (legend stays hidden).
    var titleKey: String? {
        switch self {
        case .primary:   return nil
        case .systolic:  return "Systolic"
        case .diastolic: return "Diastolic"
        }
    }
}

/// One parsed numeric value out of an average bucket.
struct WearableMetricSeriesValue: Equatable {
    let seriesKey: HealthMetricChartSeriesKey
    let value: Double
}

/// One plotted point: bucket label on x, average on y.
struct HealthMetricChartPoint: Identifiable, Equatable {
    let id = UUID()
    let label: String                        // "MON" / "JUL" / "2026"
    let seriesKey: HealthMetricChartSeriesKey
    let seriesTitle: String                  // localized legend/tooltip title
    let value: Double
    let valueText: String                    // "79.8 bpm"
}

/// One line in the Insights card below the chart.
struct HealthMetricInsight: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let valueText: String
}
