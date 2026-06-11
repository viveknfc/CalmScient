//
//  MySmokingHabitStageCardsListView.swift
//  Calmscient
//
//  Vertical list of selectable smoking habit stage cards.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MySmokingHabitStageCardsListView: View {

    @ObservedObject var viewModel: MySmokingHabitViewModel

    var body: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.stageCards) { card in
                MySmokingHabitStageCardView(card: card) {
                    viewModel.selectStage(at: card.id)
                }
            }
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Stage cards list") {
    let viewModel = MySmokingHabitViewModel()
    viewModel.applyPreviewState(selectedIndex: 0)
    return MySmokingHabitStageCardsListView(viewModel: viewModel)
        .padding(.horizontal, 20)
}
#endif
