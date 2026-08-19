//
//  HealthMetricDetailPresentation.swift
//  Calmscient
//
//  Created by NFC Solutions on 11/08/26.
//

import Foundation

// MARK: - One bar / point on the trend chart

/// A single bucket ready to draw.
///
/// `value` is optional on purpose. The averages endpoint returns every bucket in the
/// period, and the empty ones are gaps — a month with no recordings is not a month of
/// zero heart rate. Keeping the distinction here lets the chart render those as a muted
/// baseline dot instead of a bar sitting on zero.
struct HealthTrendPoint: Identifiable, Equatable {
    let id = UUID()
    /// Axis label as the server gave it: "MON", "JAN", "2026".
    let label: String
    let value: Double?
    /// Number printed above the bar. "0" for an empty bucket, matching the Android screen.
    let displayValue: String
    /// How many days in the bucket actually carried a reading, for the tap-through detail.
    let daysWithData: Int

    var hasData: Bool { value != nil }

    /// What the chart plots. Empty buckets sit on the baseline.
    var plottedValue: Double { value ?? 0 }
}

// MARK: - Everything the chart card needs

struct HealthTrendChartData: Equatable {
    let points: [HealthTrendPoint]
    /// Top of the y-axis. Rounded up to a clean number so the four gridlines read as
    /// quarters (0 / 45 / 90 / 135 / 180) rather than as arbitrary fractions of the max.
    let axisMaximum: Double
    /// Mean of the buckets that hold data, drawn as the dashed reference line.
    /// `nil` when the period is empty, so no line is drawn rather than one at zero.
    let average: Double?
    let averageText: String

    static let empty = HealthTrendChartData(points: [], axisMaximum: 100, average: nil, averageText: "--")

    var hasAnyData: Bool { points.contains(where: \.hasData) }
}

// MARK: - Buckets -> chart data

@available(iOS 16.0, *)
enum HealthTrendChartBuilder {

    /// Turns the endpoint's buckets into something drawable.
    static func make(from buckets: [WearableAverageBucket],
                     metric: HealthMetric) -> HealthTrendChartData {
        guard !buckets.isEmpty else { return .empty }

        let points: [HealthTrendPoint] = buckets.enumerated().map { index, bucket in
            let value = WearableMetricValueMapper.number(for: metric, in: bucket)
            return HealthTrendPoint(
                label: bucket.label ?? "\(index + 1)",
                value: value,
                // An empty bucket prints "0" rather than "--": it is a real statement that
                // nothing was recorded, and it matches the Android chart.
                displayValue: value.map { WearableMetricValueMapper.formatted($0, metric: metric) } ?? "0",
                daysWithData: bucket.daysWithData ?? 0)
        }

        let recorded = points.compactMap(\.value)
        let average = recorded.isEmpty ? nil : recorded.reduce(0, +) / Double(recorded.count)

        return HealthTrendChartData(
            points: points,
            axisMaximum: axisMaximum(for: metric, dataMaximum: recorded.max()),
            average: average,
            averageText: average.map {
                "\(WearableMetricValueMapper.formatted($0, metric: metric)) \(metric.unit)"
            } ?? "--")
    }

    /// Top of the y-axis.
    ///
    /// Fixed per metric rather than derived from the data, so switching between Weekly and
    /// Monthly doesn't silently rescale the chart and make the same reading look taller or
    /// shorter than it did a second ago. It only grows — never shrinks — when a real value
    /// would otherwise be drawn above the ceiling.
    static func axisMaximum(for metric: HealthMetric, dataMaximum: Double?) -> Double {
        let baseline: Double
        switch metric.id {
        case "heart_rate", "resting_hr":     baseline = 180
        case "blood_pressure":               baseline = 200
        case "hrv":                          baseline = 200
        case "spo2", "body_fat", "stress":   baseline = 100
        case "respiratory_rate":             baseline = 40
        case "steps":                        baseline = 20_000
        case "distance":                     baseline = 20
        case "active_calories":              baseline = 1_000
        case "exercise", "wellness":         baseline = 120
        case "sleep":                        baseline = 12
        case "weight":                       baseline = 150
        case "height":                       baseline = 200
        case "blood_glucose":                baseline = 200
        case "bmr":                          baseline = 3_000
        case "hydration":                    baseline = 5
        default:                             baseline = 100
        }
        guard let dataMaximum, dataMaximum > baseline else { return baseline }
        // Round the overflow up to the next quarter of the baseline so the five gridlines
        // stay whole numbers instead of becoming 43.75-style fractions.
        let step = baseline / 4
        return (dataMaximum / step).rounded(.up) * step
    }
}

// MARK: - Data source pills

/// The "Data Source" selector under the chart.
///
/// The averages endpoint has no source dimension — it returns one aggregate per bucket —
/// so this currently records a preference without re-filtering the chart. It is modelled
/// as real state (rather than hardcoded chrome) so that wiring it up is a matter of adding
/// the query parameter, not rebuilding the section.
struct HealthTrendDataSource: Identifiable, Equatable {
    let id: String
    let title: String

    static let allSources = HealthTrendDataSource(id: "all", title: "All Sources".localized)

    /// The platform's own feed, named as the Android screen names it. Not read from the
    /// response — the averages payload carries no source list — so it is a constant here
    /// until the endpoint reports which sources contributed to a bucket.
    static let platform = HealthTrendDataSource(id: "smartcenter", title: "Smartcenter")

    static let all: [HealthTrendDataSource] = [.allSources, .platform]
}

// MARK: - Insight copy

enum HealthMetricInsight {

    /// One neutral sentence per metric, mirroring the Android screen's Insight card.
    ///
    /// Deliberately descriptive rather than evaluative: this text sits under a chart of
    /// someone's own health data with no clinician in the loop, so it says what is being
    /// tracked and never whether a number is good, bad or worth acting on.
    static func text(for metric: HealthMetric) -> String {
        switch metric.id {
        case "heart_rate":
            return "Your heart rate trend is being monitored for stability and recovery.".localized
        case "resting_hr":
            return "Your resting heart rate is tracked as a baseline for recovery over time.".localized
        case "hrv":
            return "Heart rate variability is tracked alongside your rest and activity patterns.".localized
        case "spo2":
            return "Your blood oxygen readings are tracked across the selected period.".localized
        case "blood_pressure":
            return "Systolic readings are charted here; each bar is the period average.".localized
        case "respiratory_rate":
            return "Your breathing rate is tracked alongside your rest and activity.".localized
        case "stress":
            return "Your stress score is tracked to show how it moves across the period.".localized
        case "steps":
            return "Your daily step average is tracked across the selected period.".localized
        case "distance":
            return "Distance covered is tracked across the selected period.".localized
        case "active_calories":
            return "Active calories are tracked across the selected period.".localized
        case "exercise":
            return "Exercise minutes are tracked across the selected period.".localized
        case "sleep":
            return "Your sleep duration is tracked for consistency across the period.".localized
        case "weight", "height", "body_fat":
            return "Body measurements are tracked to show change over time.".localized
        case "blood_glucose":
            return "Your glucose readings are tracked across the selected period.".localized
        case "bmr":
            return "Resting energy is tracked across the selected period.".localized
        case "hydration":
            return "Your hydration is tracked across the selected period.".localized
        case "wellness":
            return "Your wellness minutes are tracked across the selected period.".localized
        default:
            return "This metric is tracked across the selected period.".localized
        }
    }
}
