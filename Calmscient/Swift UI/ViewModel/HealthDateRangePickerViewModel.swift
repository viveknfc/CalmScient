//
//  HealthDateRangePickerViewModel.swift
//  Calmscient
//
//  State for the date range popup shown over the Health Metrics screen.
//
//  It owns no navigation of its own: the host (`HealthMetricsViewModel`) hands it
//  `onSearch` / `onCancel`, so the results screen is pushed from Health Metrics and
//  back from the results lands on Health Metrics rather than on a calendar screen.
//

import Foundation
import SwiftUI

@available(iOS 16.0, *)
@MainActor
final class HealthDateRangePickerViewModel: ObservableObject {

    @Published private(set) var month: HealthCalendarMonth?
    @Published private(set) var startDate: Date?
    @Published private(set) var endDate: Date?

    /// Both dates resolved — a single tap searches that one day.
    var onSearch: ((Date, Date) -> Void)?
    var onCancel: (() -> Void)?

    let weekdaySymbols: [String] = HealthCalendarGridBuilder.weekdaySymbols()

    var monthTitle: String { month?.title ?? "" }
    var days: [HealthCalendarDay] { month?.days ?? [] }
    var canSearch: Bool { startDate != nil }

    /// The month after the visible one is only reachable while it is not ahead of today.
    var canGoForward: Bool {
        guard let month,
              let currentMonthStart = HealthCalendarGridBuilder.monthStart(of: Date()) else { return false }
        return month.monthStart < currentMonthStart
    }

    /// "16 Sep 2026 - 24 Sep 2026", or the single date, or nil while nothing is picked.
    var selectionText: String? {
        guard let startDate else { return nil }
        let start = Self.formatter.string(from: startDate)
        guard let endDate, endDate != startDate else { return start }
        return "\(start) - \(Self.formatter.string(from: endDate))"
    }

    // MARK: - Presentation

    /// Called every time the popup opens: back to today's month, selection cleared.
    func prepare() {
        startDate = nil
        endDate = nil
        month = HealthCalendarGridBuilder.month(containing: Date())
    }

    // MARK: - Month paging

    func goToPreviousMonth() {
        guard let month else { return }
        if let previous = HealthCalendarGridBuilder.month(byAdding: -1, to: month.monthStart) {
            self.month = previous
        }
    }

    func goToNextMonth() {
        guard canGoForward, let month else { return }
        if let next = HealthCalendarGridBuilder.month(byAdding: 1, to: month.monthStart) {
            self.month = next
        }
    }

    // MARK: - Selection

    func select(_ day: HealthCalendarDay) {
        guard day.isSelectable else { return }
        let date = day.date

        guard let currentStart = startDate else {
            startDate = date
            endDate = nil
            return
        }

        // A completed range starts over on the next tap.
        if endDate != nil {
            startDate = date
            endDate = nil
            return
        }

        if date < currentStart {
            startDate = date        // tapped before the anchor — move the anchor
        } else {
            endDate = date
        }
    }

    func isRangeStart(_ day: HealthCalendarDay) -> Bool {
        guard let startDate else { return false }
        return day.date == startDate
    }

    func isRangeEnd(_ day: HealthCalendarDay) -> Bool {
        guard let endDate else { return false }
        return day.date == endDate
    }

    /// Days painted with the light band between the two ends (ends included).
    func isInRange(_ day: HealthCalendarDay) -> Bool {
        guard let startDate, let endDate else { return false }
        return day.date >= startDate && day.date <= endDate
    }

    // MARK: - Actions

    func clear() {
        startDate = nil
        endDate = nil
    }

    func search() {
        guard let startDate else { return }
        onSearch?(startDate, endDate ?? startDate)
    }

    func cancel() {
        onCancel?()
    }

    // MARK: - Formatting

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()
}

#if DEBUG
@available(iOS 16.0, *)
extension HealthDateRangePickerViewModel {

    /// Preview-only model sitting on the current month. Not used in release builds.
    static func previewModel() -> HealthDateRangePickerViewModel {
        let viewModel = HealthDateRangePickerViewModel()
        viewModel.prepare()
        return viewModel
    }
}
#endif
