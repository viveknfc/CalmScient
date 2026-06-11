//
//  WeeklySummaryDashboardRowPresentation.swift
//  Calmscient
//
//  Row model for the weekly summary dashboard grid (parity with `WeeklySummaryItems`).
//
//  Vivek
//  17 May 2026
//

import Foundation

@available(iOS 16.0, *)
struct WeeklySummaryDashboardRowPresentation: Identifiable {
    let entry: WeeklySummaryDashboardCatalogEntry

    var id: String { entry.id }

    var title: String { entry.item.localized }

    var imageName: String { entry.item.getAssetName() }
}

#if DEBUG
@available(iOS 16.0, *)
enum WeeklySummaryDashboardRowPresentationPreviewData {
    static let sampleRows: [WeeklySummaryDashboardRowPresentation] =
        WeeklySummaryDashboardCatalog.gridEntries.map {
            WeeklySummaryDashboardRowPresentation(entry: $0)
        }
}
#endif
