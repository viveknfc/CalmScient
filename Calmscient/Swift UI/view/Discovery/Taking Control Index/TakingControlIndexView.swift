//
//  TakingControlIndexView.swift
//  Calmscient
//
//  SwiftUI Taking Control hub with Drinking / Smoking tabs.
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TakingControlIndexView: View {

    @ObservedObject var viewModel: TakingControlIndexViewModel

    var body: some View {
        VStack(spacing: 0) {
            TakingControlSegmentTabsView(
                drinkingTitle: "Drinking".localized,
                smokingTitle: "Smoking".localized,
                selectedSegment: Binding(
                    get: { viewModel.selectedSegment },
                    set: { viewModel.selectSegment($0) }
                )
            )
            .padding(.bottom, 4)

            Group {
                switch viewModel.selectedSegment {
                case .drinking:
                    DrinkingControlView(viewModel: viewModel.drinkingViewModel)
                case .smoking:
                    SmokingControlView(viewModel: viewModel.smokingViewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.white.ignoresSafeArea())
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Taking control index — drinking") {
    let viewModel = TakingControlIndexViewModel()
    viewModel.drinkingViewModel.applyPreviewState(
        statCards: TakingControlIndexPreviewData.drinkingStats(),
        calendarEvents: TakingControlIndexPresentation.previewCalendarEvents()
    )
    viewModel.selectSegment(.drinking)
    return TakingControlIndexView(viewModel: viewModel)
}
#endif
