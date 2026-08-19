//
//  HealthMetricRowPresentation.swift
//  Calmscient
//
//  Created by NFC Solutions on 11/08/26.
//

import Foundation

struct HealthMetricRowPresentation: Identifiable, Equatable {
    let id: String            // metric id
    let title: String         // localized
    let iconName: String
    let valueText: String     // "72 bpm" / "--"
    let isFavorite: Bool
    let metric: HealthMetric

    init(metric: HealthMetric, latest: HealthLatestValue, isFavorite: Bool = false) {
        id = metric.id
        title = metric.titleKey.localized
        iconName = metric.iconName
        valueText = latest.displayText
        self.isFavorite = isFavorite
        self.metric = metric
    }
}

struct HealthMetricSectionPresentation: Identifiable, Equatable {
    let id: String
    let title: String
    let isFavorites: Bool
    let rows: [HealthMetricRowPresentation]
    
    init(id: String, title: String, isFavorites: Bool = false,
         rows: [HealthMetricRowPresentation]) {
        self.id = id
        self.title = title
        self.isFavorites = isFavorites
        self.rows = rows
    }
}
