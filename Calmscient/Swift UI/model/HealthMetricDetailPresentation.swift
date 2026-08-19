//
//  HealthMetricDetailPresentation.swift
//  Calmscient
//
//  Created by NFC Solutions on 11/08/26.
//

import Foundation

struct HealthMetricDetailPresentation: Equatable {
    let title: String
    let chartTitle: String
    let unit: String
    let points: [HealthDataPoint]
    let insight: String
    let useBars: Bool     // bars for cumulative (steps/calories), line for discrete (HR)
}
