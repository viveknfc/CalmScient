//
//  ExercisesView.swift
//  Calmscient
//
//  SwiftUI Exercises root grid (parity with legacy `Excercises`).
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ExercisesView: View {

    @ObservedObject var viewModel: ExercisesViewModel

    var body: some View {
        ScrollView {
            ExercisesGridView(cards: viewModel.cards) { card in
                viewModel.openCard(card)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground).ignoresSafeArea())
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Exercises") {
    let viewModel = ExercisesViewModel()
    viewModel.applyPreviewState()
    return ExercisesView(viewModel: viewModel)
}
#endif
