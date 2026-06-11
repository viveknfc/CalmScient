//
//  ScreeningListView.swift
//  Calmscient
//
//  SwiftUI screenings list (parity with legacy `ScreeningListVC`).
//
//  Vivek
//  15 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ScreeningListView: View {

    @ObservedObject var viewModel: ScreeningListViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ScreeningListHeaderView(
                    title: viewModel.headerTitle,
                    subtitle: viewModel.headerSubtitle
                )

                LazyVStack(spacing: 16) {
                    ForEach(viewModel.rows) { row in
                        ScreeningListCardView(
                            title: row.title,
                            description: row.description,
                            iconURLString: row.iconURLString,
                            showsViewHistory: row.showsViewHistory,
                            viewHistoryTitle: viewModel.viewHistoryTitle,
                            takeScreeningTitle: viewModel.takeScreeningTitle,
                            onViewHistory: { viewModel.openHistory(for: row) },
                            onTakeScreening: { viewModel.openScreeningQuestions(for: row) }
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
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Screening list") {
    let viewModel = ScreeningListViewModel()
    let sampleRows = [
        ScreeningRowPresentationPreviewData.sample(
            type: "PHQ-9",
            reminder: "Evaluates symptoms of depression over the past two weeks.",
            archiveFlag: 1
        ),
        ScreeningRowPresentationPreviewData.sample(
            type: "GAD-7",
            reminder: "Measures symptoms of anxiety over the past two weeks.",
            archiveFlag: 1
        ),
        ScreeningRowPresentationPreviewData.sample(
            type: "AUDIT",
            reminder: "Screens for risky alcohol use and dependence.",
            archiveFlag: 0
        ),
    ].compactMap { $0 }
    viewModel.applyPreviewState(rows: sampleRows)
    return ScreeningListView(viewModel: viewModel)
}
#endif
