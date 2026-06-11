//
//  WeeklySummaryDashboardCatalog.swift
//  Calmscient
//
//  Single source of truth for weekly summary hub grid order and navigation targets.
//  `WeeklySummaryItems` case order does not match the dashboard (CAGE is last in the enum).
//
//  Vivek
//  17 May 2026
//

import Foundation

/// Where a dashboard tile navigates when selected.
enum WeeklySummaryDashboardDestination {
    case weeklySummaryGraph
    case progressOnCourseWork
    case journalEntry
}

/// One tile on the weekly summary dashboard grid.
struct WeeklySummaryDashboardCatalogEntry: Identifiable {
    let item: WeeklySummaryItems
    let destination: WeeklySummaryDashboardDestination

    var id: String { item.rawValue }
}

enum WeeklySummaryDashboardCatalog {

    /// Grid order shown on the weekly summary hub (parity with legacy `collectionItems`).
    static let gridEntries: [WeeklySummaryDashboardCatalogEntry] = [
        WeeklySummaryDashboardCatalogEntry(item: .WeeklySummarySummaryOfMood, destination: .weeklySummaryGraph),
        WeeklySummaryDashboardCatalogEntry(item: .WeeklySummarySummaryOfSleep, destination: .weeklySummaryGraph),
        WeeklySummaryDashboardCatalogEntry(item: .WeeklySummarySummaryOfPHQ9, destination: .weeklySummaryGraph),
        WeeklySummaryDashboardCatalogEntry(item: .WeeklySummarySummaryOfGAD, destination: .weeklySummaryGraph),
        WeeklySummaryDashboardCatalogEntry(item: .WeeklySummarySummaryOfAudit, destination: .weeklySummaryGraph),
        WeeklySummaryDashboardCatalogEntry(item: .WeeklySummarySummaryOfDast, destination: .weeklySummaryGraph),
        WeeklySummaryDashboardCatalogEntry(item: .WeeklySummaryCAGE, destination: .weeklySummaryGraph),
        WeeklySummaryDashboardCatalogEntry(item: .WeeklySummaryProgressOnCourseWork, destination: .progressOnCourseWork),
        WeeklySummaryDashboardCatalogEntry(item: .WeeklySummaryJournalEntry, destination: .journalEntry),
    ]

    static var gridItems: [WeeklySummaryItems] {
        gridEntries.map(\.item)
    }
}

#if DEBUG
enum WeeklySummaryDashboardCatalogPreviewData {
    static let sampleEntries = WeeklySummaryDashboardCatalog.gridEntries
}
#endif
