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

    var body: some View {
        WeeklySummaryGraphSleepSummaryRepresentable(
            presentation: presentation,
            title: title,
            mostHoursTitle: mostHoursTitle,
            averageHoursTitle: averageHoursTitle,
            leastHoursTitle: leastHoursTitle
        )
        .frame(height: 300)
        .padding(.horizontal, 8)
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
