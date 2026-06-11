//
//  WeeklySummaryDashboardViewModel.swift
//  Calmscient
//
//  State and navigation for the SwiftUI weekly summary hub (parity with `WeeklySummaryDashboardViewController`).
//
//  Vivek
//  17 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class WeeklySummaryDashboardViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var screenTitle: String = ""
    @Published private(set) var rows: [WeeklySummaryDashboardRowPresentation] = []

    private let catalogEntries = WeeklySummaryDashboardCatalog.gridEntries

    init() {
        reloadLocalizedStrings()
    }

    func reloadLocalizedStrings() {
        screenTitle = "Weekly summary".localized
        rows = catalogEntries.map { WeeklySummaryDashboardRowPresentation(entry: $0) }
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
    }

    func openBack() {
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    func openRow(at index: Int) {
        guard let nav = hostViewController?.navigationController else { return }
        guard catalogEntries.indices.contains(index) else { return }

        guard NetworkMonitor.shared.isConnected else {
            NoInternetBanner.shared.openDetails()
            return
        }

        WeeklySummaryDashboardNavigation.push(entry: catalogEntries[index], from: nav)
    }
}
