//
//  HealthMetricDetailViewModel.swift
//  Calmscient
//
//  Loads a single metric's trend for the selected Daily/Weekly/Monthly/Yearly
//  range from HealthKit for the detail chart.
//
//  11 August 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class HealthMetricDetailViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    let metric: HealthMetricType

    @Published var range: TrendRange = .weekly {
        didSet { reload() }
    }
    @Published private(set) var points: [MetricPoint] = []
    @Published private(set) var isLoading = false

    private let repository = HealthMetricsRepository.shared

    init(metric: HealthMetricType) {
        self.metric = metric
    }

    var screenTitle: String { metric.title }

    /// Whether cumulative metrics should render as bars vs. a line for averages.
    var usesBars: Bool { metric.aggregation == .cumulativeSum || metric.aggregation == .categoryDuration }

    /// Summary shown above the chart (total for cumulative, average otherwise).
    var summaryText: String {
        guard !points.isEmpty else { return "--" }
        let values = points.map(\.value)
        let stat: Double
        let label: String
        if usesBars {
            stat = values.reduce(0, +)
            label = "Total"
        } else {
            let nonZero = values.filter { $0 > 0 }
            stat = nonZero.isEmpty ? 0 : nonZero.reduce(0, +) / Double(nonZero.count)
            label = "Average"
        }
        return "\(label): \(String(format: "%.\(metric.fractionDigits)f", stat)) \(metric.unit)"
    }

    func onAppear() { reload() }

    func reload() {
        Task {
            isLoading = true
            _ = await repository.requestAuthorization()
            points = await repository.trend(for: metric, range: range)
            isLoading = false
        }
    }

    func openBack() {
        hostViewController?.navigationController?.popViewController(animated: true)
    }
}
