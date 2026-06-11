//
//  USGuideLineForDrinkingSectionView.swift
//  Calmscient
//
//  One guidelines section (header + Men/Women cards).
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct USGuideLineForDrinkingSectionView: View {

    let section: USDrinkingGuidelineSectionPresentation

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            USGuideLineForDrinkingSectionHeaderView(section: section)

            ForEach(section.cards) { card in
                USGuideLineForDrinkingGuidelineCardView(card: card)
            }
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Guidelines section — standard") {
    USGuideLineForDrinkingSectionView(
        section: USDrinkingGuidelineSectionPresentation.previewSections()[0]
    )
    .padding(.horizontal, 20)
}

@available(iOS 16.0, *)
#Preview("Guidelines section — heavy drinking") {
    USGuideLineForDrinkingSectionView(
        section: USDrinkingGuidelineSectionPresentation.previewSections()[1]
    )
    .padding(.horizontal, 20)
}
#endif
