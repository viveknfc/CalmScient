//
//  ExercisesGridView.swift
//  Calmscient
//
//  Two-column grid of exercise cards.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ExercisesGridView: View {

    let cards: [ExercisesCardItem]
    let onCardTap: (ExercisesCardItem) -> Void

    /// Matches legacy `Excercises` flow layout (`sectionInset` / `minimumInteritemSpacing` / `minimumLineSpacing` = 10).
    private let columnSpacing: CGFloat = 10
    private let rowSpacing: CGFloat = 10
    private let horizontalInset: CGFloat = 10

    var body: some View {
        VStack(spacing: rowSpacing) {
            ForEach(rowIndices, id: \.self) { rowStart in
                HStack(alignment: .top, spacing: columnSpacing) {
                    cardCell(at: rowStart)
                    if rowStart + 1 < cards.count {
                        cardCell(at: rowStart + 1)
                    } else {
                        Color.clear
                            .frame(maxWidth: .infinity)
                            .accessibilityHidden(true)
                    }
                }
            }
        }
        .padding(.horizontal, horizontalInset)
        .padding(.top, 10)
        .padding(.bottom, 24)
    }

    private var rowIndices: [Int] {
        stride(from: 0, to: cards.count, by: 2).map { $0 }
    }

    @ViewBuilder
    private func cardCell(at index: Int) -> some View {
        let card = cards[index]
        ExercisesCardView(
            title: card.titleKey.localized,
            imageName: card.imageName
        ) {
            onCardTap(card)
        }
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG
@available(iOS 16.0, *)
extension ExercisesCardItem {
    static var previewSamples: [ExercisesCardItem] {
        [
            ExercisesCardItem(
                id: 0,
                titleKey: "Mindfulness - what is it?",
                imageName: "mindfulness",
                destination: .mindfulness
            ),
            ExercisesCardItem(
                id: 1,
                titleKey: "Progressive muscle relaxation",
                imageName: "progressiveWithHeadset",
                destination: .progressiveMuscleRelaxation
            ),
            ExercisesCardItem(
                id: 8,
                titleKey: "Breathing technique",
                imageName: "breathingTechnique",
                destination: .breathingTechnique
            ),
        ]
    }
}

@available(iOS 16.0, *)
#Preview("Exercises grid") {
    ScrollView {
        ExercisesGridView(cards: ExercisesCardItem.previewSamples) { _ in }
    }
    .background(Color(uiColor: .systemBackground))
}
#endif
