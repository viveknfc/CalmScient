//
//  WeeklySummaryDashboardView.swift
//  Calmscient
//
//  SwiftUI weekly summary hub (parity with `WeeklySummaryDashboardViewController`).
//
//  Vivek
//  17 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct WeeklySummaryDashboardView: View {

    @ObservedObject var viewModel: WeeklySummaryDashboardViewModel

    private let edgeGutter: CGFloat = 16
    private let columnSpacing: CGFloat = 10
    private let rowSpacing: CGFloat = 16
    private let tileHeight: CGFloat = 125

    private var rowStartIndices: [Int] {
        stride(from: 0, to: viewModel.rows.count, by: 2).map { $0 }
    }

    var body: some View {
        GeometryReader { geometry in
            // `GeometryReader` reports 0 (and, mid-transition, occasionally a non-finite
            // value) before the first layout pass. Subtracting the gutters from that made
            // `gridWidth` negative, which UIKit rejects with
            // "Invalid frame dimension (negative or non-finite)". Sanitising the proposed
            // width keeps every derived dimension >= 0 without changing the laid-out sizes.
            let availableWidth = Self.sanitized(geometry.size.width)
            let gridWidth = max(0, availableWidth - (edgeGutter * 2))
            let columnWidth = Self.columnWidth(
                for: availableWidth,
                edgeGutter: edgeGutter,
                columnSpacing: columnSpacing
            )

            ScrollView {
                HStack(alignment: .top, spacing: 0) {
                    fixedGutter(width: edgeGutter)

                    VStack(spacing: rowSpacing) {
                        ForEach(rowStartIndices, id: \.self) { startIndex in
                            gridRow(startingAt: startIndex, columnWidth: columnWidth)
                        }
                    }
                    .frame(width: gridWidth)

                    fixedGutter(width: edgeGutter)
                }
                .padding(.top, edgeGutter)
                .padding(.bottom, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(LoginDesignSystem.ColorName.pageBackground.ignoresSafeArea())
    }

    private static func columnWidth(
        for totalWidth: CGFloat,
        edgeGutter: CGFloat,
        columnSpacing: CGFloat
    ) -> CGFloat {
        max(0, (totalWidth - (edgeGutter * 2) - columnSpacing) / 2)
    }

    /// Non-finite or negative proposals become 0 — never a frame UIKit will reject.
    private static func sanitized(_ value: CGFloat) -> CGFloat {
        guard value.isFinite, value > 0 else { return 0 }
        return value
    }

    private func fixedGutter(width: CGFloat) -> some View {
        Color.clear
            .frame(width: width)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private func gridRow(startingAt startIndex: Int, columnWidth: CGFloat) -> some View {
        HStack(alignment: .top, spacing: 0) {
            tileCell(at: startIndex, columnWidth: columnWidth)

            fixedGutter(width: columnSpacing)

            if startIndex + 1 < viewModel.rows.count {
                tileCell(at: startIndex + 1, columnWidth: columnWidth)
            } else {
                Color.clear
                    .frame(width: columnWidth, height: tileHeight)
                    .accessibilityHidden(true)
            }
        }
    }

    private func tileCell(at index: Int, columnWidth: CGFloat) -> some View {
        tile(at: index)
            .frame(width: columnWidth, height: tileHeight)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: WeeklySummaryDashboardTileView.cornerRadius,
                    style: .continuous
                )
            )
    }

    private func tile(at index: Int) -> some View {
        let row = viewModel.rows[index]
        return WeeklySummaryDashboardTileView(
            title: row.title,
            imageName: row.imageName,
            onTap: { viewModel.openRow(at: index) }
        )
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Weekly summary dashboard") {
    WeeklySummaryDashboardView(viewModel: WeeklySummaryDashboardViewModel())
}
#endif
