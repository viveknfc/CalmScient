//
//  TakingControlIndexPresentation.swift
//  Calmscient
//
//  Presentation models for Taking Control index (drinking / smoking tabs).
//
//  Vivek
//  20 May 2026
//

import SwiftUI

enum TakingControlSegment: Int, CaseIterable {
    case drinking = 0
    case smoking = 1
}

struct TakingControlStatCardPresentation: Identifiable, Equatable {
    let id: String
    let title: String
    let value: String
    let subtitle: String?
    let systemImageName: String?
    let assetImageName: String?
}

struct TakingControlMenuItemPresentation: Identifiable, Equatable {
    let id: Int
    let title: String
    let isActive: Bool
    let showsCheckmark: Bool
}

struct TakingControlResourceRowPresentation: Identifiable, Equatable {
    let id: Int
    let title: String
    let description: String
    let imageName: String
}

struct TakingControlCalendarEventPresentation: Identifiable, Equatable {
    let id: String
    let date: Date
    let dotColor: Color
}

struct TakingControlInfoLegendItem: Identifiable, Equatable {
    let id: String
    let title: String
    let dotColor: Color
}

enum TakingControlIndexPresentation {

    static func drinkingInfoLegend() -> [TakingControlInfoLegendItem] {
        [
            TakingControlInfoLegendItem(
                id: "alcohol_free",
                title: "Alcohol-free day".localized,
                dotColor: Color(red: 0.429, green: 0.420, blue: 0.682)
            ),
            TakingControlInfoLegendItem(
                id: "upcoming_alcohol_free",
                title: "Upcoming alcohol-free day".localized,
                dotColor: Color(red: 0.289, green: 0.599, blue: 0.431)
            ),
            TakingControlInfoLegendItem(
                id: "hangover",
                title: "Hangover, argument, accident".localized,
                dotColor: Color(red: 0.900, green: 0.435, blue: 0.239)
            ),
            TakingControlInfoLegendItem(
                id: "over_moderation",
                title: "Drink more than moderation".localized,
                dotColor: Color(red: 0.951, green: 0.664, blue: 0.259)
            ),
            TakingControlInfoLegendItem(
                id: "in_moderation",
                title: "Drink in moderation".localized,
                dotColor: Color(red: 0.635, green: 0.844, blue: 0.984)
            ),
        ]
    }

    static func calendarEvents(from intoDates: [IntoDate]?) -> [TakingControlCalendarEventPresentation] {
        guard let intoDates else { return [] }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        return intoDates.compactMap { item -> TakingControlCalendarEventPresentation? in
            guard let dateString = item.eventDate,
                  let date = formatter.date(from: dateString) else {
                return nil
            }
            let day = Calendar.current.startOfDay(for: date)
            let color = colorForCalendarCode(item.colorCode)
            return TakingControlCalendarEventPresentation(
                id: MedicalCalendarStripLogic.stripDayIdentifier(for: day),
                date: day,
                dotColor: color
            )
        }
    }

    static func previewCalendarEvents(around center: Date = Date()) -> [TakingControlCalendarEventPresentation] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: center)
        return [
            (cal.date(byAdding: .day, value: -2, to: today)!, Color.green),
            (cal.date(byAdding: .day, value: -1, to: today)!, Color.red),
            (cal.date(byAdding: .day, value: 1, to: today)!, Color.orange),
            (cal.date(byAdding: .day, value: 2, to: today)!, Color.purple),
        ].map { date, color in
            TakingControlCalendarEventPresentation(
                id: MedicalCalendarStripLogic.stripDayIdentifier(for: date),
                date: date,
                dotColor: color
            )
        }
    }

    private static func colorForCalendarCode(_ code: String?) -> Color {
        guard let code = code?.lowercased() else { return .red }
        if code.contains("green") { return Color(red: 0.289, green: 0.599, blue: 0.431) }
        if code.contains("orange") { return Color(red: 0.951, green: 0.664, blue: 0.259) }
        if code.contains("purple") { return Color(red: 0.429, green: 0.420, blue: 0.682) }
        if code.contains("blue") { return Color(red: 0.635, green: 0.844, blue: 0.984) }
        if code.hasPrefix("#") {
            return Color(UIColor(hex: code))
        }
        return .red
    }
}

#if DEBUG
enum TakingControlIndexPreviewData {
    static func drinkingStats() -> [TakingControlStatCardPresentation] {
        [
            TakingControlStatCardPresentation(
                id: "left",
                title: "Drink Counts".localized,
                value: "0",
                subtitle: nil,
                systemImageName: "arrow.counterclockwise.circle",
                assetImageName: nil
            ),
            TakingControlStatCardPresentation(
                id: "right",
                title: "Alcohol free days".localized,
                value: "0",
                subtitle: nil,
                systemImageName: nil,
                assetImageName: "alcoholImage"
            ),
        ]
    }

    static func smokingStats() -> [TakingControlStatCardPresentation] {
        [
            TakingControlStatCardPresentation(
                id: "left",
                title: "Smoking free time".localized,
                value: "24",
                subtitle: "Days".localized,
                systemImageName: "calendar",
                assetImageName: nil
            ),
            TakingControlStatCardPresentation(
                id: "right",
                title: "Saving".localized,
                value: "192",
                subtitle: "USD($)".localized,
                systemImageName: "wallet.pass",
                assetImageName: nil
            ),
        ]
    }
}
#endif
