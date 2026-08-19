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

    // MARK: - SwiftUI navigation
    //
    // Set by `HomeTabView` when this screen is shown inside the Home `NavigationStack`.
    // While nil, every call below falls through to the existing UIKit push/pop, which is
    // what the still-UIKit Discovery tab uses when it pushes into these screens.
    var onOpenRoute: ((HomeRoute) -> Void)?
    var onClose: (() -> Void)?
    var onCloseToRoot: (() -> Void)?

    @Published private(set) var screenTitle: String = ""
    @Published private(set) var rows: [WeeklySummaryDashboardRowPresentation] = []

    private let catalogEntries = WeeklySummaryDashboardCatalog.gridEntries

    init() {
        reloadLocalizedStrings()
    }

    /// Recomputes the localized chrome, publishing only what actually changed.
    ///
    /// This runs on every appearance, and the appearance callback is bridged out of UIKit
    /// while SwiftUI is updating — so an unconditional assignment logged "Publishing
    /// changes from within view updates is not allowed" even though nothing had changed.
    func reloadLocalizedStrings() {
        let title = "Weekly summary".localized
        if screenTitle != title { screenTitle = title }

        let presentations = catalogEntries.map { WeeklySummaryDashboardRowPresentation(entry: $0) }
        if !Self.rowsMatch(rows, presentations) {
            rows = presentations
        }
    }

    private static func rowsMatch(
        _ lhs: [WeeklySummaryDashboardRowPresentation],
        _ rhs: [WeeklySummaryDashboardRowPresentation]
    ) -> Bool {
        guard lhs.count == rhs.count else { return false }
        return !zip(lhs, rhs).contains {
            $0.id != $1.id || $0.title != $1.title || $0.imageName != $1.imageName
        }
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
    }

    func openBack() {
        if let onClose {
            onClose()
            return
        }
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    func openRow(at index: Int) {
        guard catalogEntries.indices.contains(index) else { return }

        guard NetworkMonitor.shared.isConnected else {
            NoInternetBanner.shared.openDetails()
            return
        }

        if let onOpenRoute {
            let entry = catalogEntries[index]
            switch entry.destination {
            case .weeklySummaryGraph: onOpenRoute(.weeklySummaryGraph(entry.item))
            case .progressOnCourseWork: onOpenRoute(.progressOnCourseWork)
            case .journalEntry: onOpenRoute(.journalEntry)
            }
            return
        }

        guard let nav = hostViewController?.navigationController else { return }
        WeeklySummaryDashboardNavigation.push(entry: catalogEntries[index], from: nav)
    }
}
