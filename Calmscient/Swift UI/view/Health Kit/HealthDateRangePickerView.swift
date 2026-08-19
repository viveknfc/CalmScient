//
//  HealthDateRangePickerView.swift
//  Calmscient
//
//  Date range popup shown over the Health Metrics screen: one month at a time,
//  chevron paging, a highlighted range and Clear / Search actions.
//

import SwiftUI
import UIKit

// MARK: - Range band
//
// The light band behind the days between the two ends. Rounded on the side where
// the range starts or ends (and at the edges of each week) so it reads as one
// continuous pill per row.

@available(iOS 16.0, *)
private struct HealthCalendarBandShape: Shape {
    let roundsLeading: Bool
    let roundsTrailing: Bool

    func path(in rect: CGRect) -> Path {
        var corners: UIRectCorner = []
        if roundsLeading { corners.insert(.topLeft); corners.insert(.bottomLeft) }
        if roundsTrailing { corners.insert(.topRight); corners.insert(.bottomRight) }
        guard !corners.isEmpty else { return Path(rect) }

        let radius = rect.height / 2
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Popup

@available(iOS 16.0, *)
struct HealthDateRangePickerView: View {

    @ObservedObject var viewModel: HealthDateRangePickerViewModel

    private enum Style {
        static let accent = Color(hex: "#6D6BB3")
        static let band = Color(hex: "#6D6BB3").opacity(0.14)
        static let mutedText = Color(hex: "#B4B4C4")
        static let separator = Color(hex: "#ECEAF4")
        static let cellHeight: CGFloat = 38
        static let selectionDiameter: CGFloat = 34
        static let cardWidth: CGFloat = 330
        /// Close button: circle diameter and the tint behind the glyph.
        static let closeDiameter: CGFloat = 28
        static let closeBackground = Color(hex: "#6D6BB3").opacity(0.10)
    }

    /// Six rows of seven, exactly as the grid was built.
    private var weeks: [[HealthCalendarDay]] {
        let days = viewModel.days
        guard days.count >= 7 else { return [] }
        return stride(from: 0, to: days.count, by: 7).map { start in
            Array(days[start..<min(start + 7, days.count)])
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.32)
                .ignoresSafeArea()
                .onTapGesture { viewModel.cancel() }

            card
                .frame(width: Style.cardWidth)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: Color.black.opacity(0.16), radius: 24, x: 0, y: 12)
                .padding(.horizontal, 20)
        }
    }

    private var card: some View {
        VStack(spacing: 0) {
            closeRow
            header
            weekdayRow
            grid
            selectionSummary
            Divider().background(Style.separator)
            actions
        }
    }

    // MARK: - Close

    // Sits on its own row so the month title and the paging chevrons below keep
    // their symmetry — nothing in the header row shifts to make space for it.
    private var closeRow: some View {
        HStack {
            Spacer(minLength: 0)

            Button {
                viewModel.cancel()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.primary.opacity(0.7))
                    .frame(width: Style.closeDiameter, height: Style.closeDiameter)
                    .background(Circle().fill(Style.closeBackground))
                    .contentShape(Circle())
            }
            .accessibilityLabel("Close".localized)
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            chevron(systemName: "chevron.left", isEnabled: true) {
                viewModel.goToPreviousMonth()
            }

            Spacer(minLength: 8)

            Text(viewModel.monthTitle)
                .font(.custom(Fonts().lexendSemiBold, size: 16))
                .foregroundStyle(Color.primary)

            Spacer(minLength: 8)

            chevron(systemName: "chevron.right", isEnabled: viewModel.canGoForward) {
                viewModel.goToNextMonth()
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 6)
        .padding(.bottom, 14)
    }

    private func chevron(systemName: String, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isEnabled ? Color.primary.opacity(0.7) : Style.mutedText)
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
        }
        .disabled(!isEnabled)
    }

    // MARK: - Weekdays

    private var weekdayRow: some View {
        HStack(spacing: 0) {
            ForEach(Array(viewModel.weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.custom(Fonts().lexendMedium, size: 12))
                    .foregroundStyle(Color.primary.opacity(0.75))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 10)
    }

    // MARK: - Grid

    private var grid: some View {
        VStack(spacing: 2) {
            ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                HStack(spacing: 0) {
                    ForEach(Array(week.enumerated()), id: \.element.id) { column, day in
                        dayCell(day, column: column)
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 14)
    }

    private func dayCell(_ day: HealthCalendarDay, column: Int) -> some View {
        let isStart = viewModel.isRangeStart(day)
        let isEnd = viewModel.isRangeEnd(day)
        let isEdge = isStart || isEnd
        let isInRange = viewModel.isInRange(day)

        return ZStack {
            if isInRange {
                HealthCalendarBandShape(
                    roundsLeading: isStart || column == 0,
                    roundsTrailing: isEnd || column == 6)
                    .fill(Style.band)
            }

            if isEdge {
                Circle()
                    .fill(Style.accent)
                    .frame(width: Style.selectionDiameter, height: Style.selectionDiameter)
            }

            Text(day.dayNumber)
                .font(.custom(isEdge || isInRange ? Fonts().lexendMedium : Fonts().lexendRegular, size: 14))
                .foregroundStyle(textColor(day, isEdge: isEdge, isInRange: isInRange))
        }
        .frame(maxWidth: .infinity)
        .frame(height: Style.cellHeight)
        .contentShape(Rectangle())
        .onTapGesture { viewModel.select(day) }
    }

    private func textColor(_ day: HealthCalendarDay, isEdge: Bool, isInRange: Bool) -> Color {
        if isEdge { return .white }
        if isInRange { return Style.accent }
        guard day.isWithinMonth else { return Style.mutedText }
        return day.isSelectable ? Color.primary : Style.mutedText
    }

    // MARK: - Selection summary

    @ViewBuilder
    private var selectionSummary: some View {
        if let selectionText = viewModel.selectionText {
            Text(selectionText)
                .font(.custom(Fonts().lexendRegular, size: 12))
                .foregroundStyle(.secondary)
                .padding(.bottom, 14)
        }
    }

    // MARK: - Actions

    private var actions: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.clear()
            } label: {
                Text("Clear".localized)
                    .font(.custom(Fonts().lexendMedium, size: 14))
                    .foregroundStyle(Color.primary.opacity(0.75))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(
                        Capsule().stroke(Style.separator, lineWidth: 1)
                    )
            }

            Button {
                viewModel.search()
            } label: {
                Text("Search".localized)
                    .font(.custom(Fonts().lexendMedium, size: 14))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(
                        Capsule().fill(viewModel.canSearch ? Style.accent : Style.accent.opacity(0.4))
                    )
            }
            .disabled(!viewModel.canSearch)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
    }
}

#if DEBUG
@available(iOS 16.0, *)
struct HealthDateRangePickerView_Previews: PreviewProvider {
    static var previews: some View {
        HealthDateRangePickerView(viewModel: .previewModel())
    }
}
#endif
