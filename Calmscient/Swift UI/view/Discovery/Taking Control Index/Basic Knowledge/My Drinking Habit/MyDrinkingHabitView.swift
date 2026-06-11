//
//  MyDrinkingHabitView.swift
//  Calmscient
//
//  SwiftUI My Drinking Habit screen (parity with `MyDrinkingHabitVC`).
//
//  Vivek
//  25 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MyDrinkingHabitView: View {

    @ObservedObject var viewModel: MyDrinkingHabitViewModel

    private let pageBackground = Color("AppViewContentColor")

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                MyDrinkingHabitHeaderSectionView(viewModel: viewModel)
                    .padding(.top, 20)

                MyDrinkingHabitHabitCardsListView(viewModel: viewModel)

                MyDrinkingHabitJournalSectionView(viewModel: viewModel)

                MyDrinkingHabitForwardFabView(
                    accessibilityLabel: viewModel.forwardFabAccessibilityLabel,
                    action: viewModel.forwardTapped
                )
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(pageBackground.ignoresSafeArea())
        .overlay {
            if viewModel.isSavingJournal {
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
#Preview("My drinking habit screen") {
    let viewModel = MyDrinkingHabitViewModel()
    viewModel.applyPreviewState(selectedIndex: 0)
    return MyDrinkingHabitView(viewModel: viewModel)
}
#endif
