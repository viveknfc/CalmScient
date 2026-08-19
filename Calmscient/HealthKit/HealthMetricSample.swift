//
//  HealthMetricSample.swift
//  Calmscient
//
//  Created by NFC Solutions on 11/08/26.
//

import Foundation

/// A single point on a chart (one bucket: a day, week, month or year).
struct HealthDataPoint: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let value: Double
    /// Pre-formatted x-axis label ("Mon", "W1", "Jan", "2025").
    let label: String
}

/// The latest single reading shown on the dashboard row.
struct HealthLatestValue: Equatable {
    let value: Double?
    let displayText: String   // "72 bpm", "120/80 mmHg", "--"
}

/// Chart timeframe (matches the segmented control in your Android screenshots).
enum HealthTimeframe: String, CaseIterable, Identifiable {
    case daily   = "Daily"
    case weekly  = "Weekly"
    case monthly = "Monthly"
    case yearly  = "Yearly"

    var id: String { rawValue }
    var localizedTitle: String { rawValue.localized }
}
