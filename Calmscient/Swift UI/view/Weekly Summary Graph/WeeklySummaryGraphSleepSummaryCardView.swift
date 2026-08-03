//
//  WeeklySummaryGraphSleepSummaryCardView.swift
//  Calmscient
//
//  Sleep average summary card (parity with `SleepSummaryTableViewCell`).
//
//  Vivek
//  18 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct WeeklySummaryGraphSleepSummaryCardView: View {

    let presentation: WeeklySummaryGraphSleepPresentation
    let title: String
    let mostHoursTitle: String
    let averageHoursTitle: String
    let leastHoursTitle: String

    private var averageValue: Float {
        Float(presentation.averageHoursText) ?? 0
    }

    private var progressColor: Color {
        // Parity with `SleepSummaryTableViewCell.getProgressColor(for:)`.
        switch Int(averageValue) {
        case 6...8:
            return .green
        case 0...5, 9...12:
            return .red
        default:
            return .gray
        }
    }

    private var clampedProgress: CGFloat {
        CGFloat(min(max(presentation.progress, 0), 1))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.custom(Fonts().lexendRegular, size: 16))
                .foregroundStyle(Color.primary)

            progressBar

            averageText

            VStack(spacing: 12) {
                infoRow(title: mostHoursTitle, value: presentation.mostHoursText)
                infoRow(title: averageHoursTitle, value: presentation.averageHoursDetailText)
                infoRow(title: leastHoursTitle, value: presentation.leastHoursText)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.25))
                Capsule()
                    .fill(progressColor)
                    .frame(width: geometry.size.width * clampedProgress)
            }
        }
        .frame(height: 12)
    }

    private var averageText: some View {
        (
            Text("\(presentation.averageHoursText) / ")
                .foregroundColor(Color(UIColor(hex: "#9B9B9B")))
            + Text(presentation.averageHoursDenominator)
                .foregroundColor(Color.primary)
        )
        .font(.custom(Fonts().lexendMedium, size: 14))
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.custom(Fonts().lexendLight, size: 14))
                .foregroundStyle(Color.primary)
            Spacer()
            Text(value)
                .font(.custom(Fonts().lexendMedium, size: 14))
                .foregroundStyle(Color.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.10))
        )
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Sleep summary card") {
    WeeklySummaryGraphSleepSummaryCardView(
        presentation: WeeklySummaryGraphPresentationPreviewData.sampleSleepSummary(),
        title: "Average sleep score",
        mostHoursTitle: "Most hours slept",
        averageHoursTitle: "Average hours slept",
        leastHoursTitle: "Least hours slept"
    )
}
#endif
