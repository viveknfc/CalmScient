//
//  HistoryView.swift
//  Calmscient
//
//  SwiftUI screening history list (parity with legacy `HistoryVC`).
//
//  Vivek
//  15 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct HistoryView: View {

    @ObservedObject var viewModel: HistoryViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if !viewModel.screeningTitle.isEmpty {
                    HistoryScreeningTitleView(title: viewModel.screeningTitle)
                }

                LazyVStack(spacing: 16) {
                    ForEach(viewModel.rows) { row in
                        HistoryCardView(
                            dateTimeText: row.dateTimeText,
                            score: row.score,
                            totalScore: row.totalScore,
                            progress: row.progress
                        )
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("History list") {
    let viewModel = HistoryViewModel()
    let rows = [
        HistoryRowPresentationPreviewData.sample(
            completionDateTime: "2026-05-12 12:35:00",
            score: 25,
            totalScore: 30
        ),
        HistoryRowPresentationPreviewData.sample(
            completionDateTime: "2026-04-29 13:28:00",
            score: 17,
            totalScore: 30
        ),
    ].compactMap { $0 }
    viewModel.applyPreviewState(screeningTitle: "PHQ-9", rows: rows)
    return HistoryView(viewModel: viewModel)
}
#endif
