//
//  WeeklySummaryDashboardNavigation.swift
//  Calmscient
//
//  UIKit navigation from a weekly summary dashboard catalog entry.
//
//  Vivek
//  18 May 2026
//

import UIKit

enum WeeklySummaryDashboardNavigation {

    @MainActor
    static func push(
        entry: WeeklySummaryDashboardCatalogEntry,
        from navigationController: UINavigationController
    ) {
        switch entry.destination {
        case .weeklySummaryGraph:
            let host = WeeklySummaryGraphHostingController()
            host.configure(summaryType: entry.item)
            navigationController.pushViewController(host, animated: true)

        case .progressOnCourseWork:
            navigationController.pushViewController(
                ProgressOnCourseWorkHostingController(),
                animated: true
            )

        case .journalEntry:
            navigationController.pushViewController(JournalEntryHostingController(), animated: true)
        }
    }
}
