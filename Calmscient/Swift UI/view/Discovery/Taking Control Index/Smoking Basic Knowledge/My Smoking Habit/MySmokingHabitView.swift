//
//  MySmokingHabitView.swift
//  Calmscient
//
//  SwiftUI My Smoking Habit screen (parity with `MySmokingHabitVC`).
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MySmokingHabitView: View {

    @ObservedObject var viewModel: MySmokingHabitViewModel

    private let pageBackground = Color("AppViewContentColor")

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                MySmokingHabitHeaderSectionView(viewModel: viewModel)
                    .padding(.top, 20)

                MySmokingHabitStageCardsListView(viewModel: viewModel)

                MySmokingHabitJournalSectionView(viewModel: viewModel)

                BasicKnowledgeCompleteButtonView(
                    title: viewModel.completeButtonTitle,
                    onTap: viewModel.completeTapped
                )
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(pageBackground.ignoresSafeArea())
        .overlay {
            if viewModel.isSavingJournal || viewModel.isCompleting {
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
#Preview("My smoking habit screen") {
    let viewModel = MySmokingHabitViewModel()
    viewModel.applyPreviewState(selectedIndex: 0)
    return MySmokingHabitView(viewModel: viewModel)
}
#endif
