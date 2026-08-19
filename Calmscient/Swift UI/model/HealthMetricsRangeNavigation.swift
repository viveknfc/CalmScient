//
//  HealthMetricsRangeNavigation.swift
//  Calmscient
//
//  UIKit push helpers for the calendar branch of Health Metrics, mirroring
//  `HealthMetricDetailNavigation`. Only used when a screen is running outside the
//  SwiftUI Home `NavigationStack` (the still-UIKit Discovery tab).
//

import UIKit

enum HealthMetricsRangeNavigation {

    @available(iOS 16.0, *)
    @MainActor
    static func pushResults(from host: UIViewController, startDate: Date, endDate: Date) {
        guard let nav = host.navigationController else { return }
        nav.pushViewController(
            HealthDataRangeHostingController(startDate: startDate, endDate: endDate),
            animated: true)
    }
}
