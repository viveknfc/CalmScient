//
//  JournalEntryPresentation.swift
//  Calmscient
//
//  Row and section models for the journal entry hub (quiz, daily journal, discovery).
//
//  Vivek
//  18 May 2026
//

import Foundation

@available(iOS 16.0, *)
struct JournalQuizRowPresentation: Identifiable, Hashable {
    let id: String
    let sectionTitle: String
    let dateTimeText: String
    let score: Int
    let totalScore: Int

    var progress: Double {
        guard totalScore > 0 else { return 0 }
        return min(max(Double(score) / Double(totalScore), 0), 1)
    }
}

@available(iOS 16.0, *)
struct JournalDailyRowPresentation: Identifiable, Hashable {
    let id: String
    let createdAtRaw: String
    let timeText: String
    let bodyText: String
}

@available(iOS 16.0, *)
struct JournalDailySectionPresentation: Identifiable, Hashable {
    let id: String
    let headerText: String
    var rows: [JournalDailyRowPresentation]
}

@available(iOS 16.0, *)
struct JournalDiscoveryRowPresentation: Identifiable, Hashable {
    let id: String
    let createdAtRaw: String
    let dateText: String
    let entryTitle: String
    let bodyPreview: String
    let bulletLines: [String]
}
