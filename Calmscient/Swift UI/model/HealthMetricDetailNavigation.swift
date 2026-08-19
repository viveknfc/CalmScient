//
//  HealthMetricDetailNavigation.swift
//  Calmscient
//
//  Created by NFC Solutions on 12/08/26.


import UIKit

enum HealthMetricDetailNavigation {

    @available(iOS 16.0, *)
    @MainActor
    static func push(from host: UIViewController, metric: HealthMetric) {
        guard let nav = host.navigationController else { return }
        nav.pushViewController(HealthMetricDetailHostingController(metric: metric), animated: true)
    }
}
