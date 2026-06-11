//
//  MyDrinkingHabitHabitCardsListView.swift
//  Calmscient
//
//  Vertical list of selectable drinking habit cards.
//
//  Vivek
//  25 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MyDrinkingHabitHabitCardsListView: View {

    @ObservedObject var viewModel: MyDrinkingHabitViewModel

    var body: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.habitCards) { card in
                MyDrinkingHabitHabitCardView(card: card) {
                    viewModel.selectHabit(at: card.id)
                }
            }
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Habit cards list") {
    let viewModel = MyDrinkingHabitViewModel()
    viewModel.applyPreviewState(selectedIndex: 0)
    return MyDrinkingHabitHabitCardsListView(viewModel: viewModel)
        .padding(.horizontal, 20)
}
#endif
