//
//  TryingToQuitView.swift
//  Calmscient
//
//  SwiftUI trying-to-quit screen (parity with legacy `TryingToQuitVC`).
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TryingToQuitView: View {

    @ObservedObject var viewModel: TryingToQuitViewModel

    private let pageBackground = Color(.systemBackground)

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    BasicStandardDrinkHeaderView(title: viewModel.content.headerTitle)
                        .padding(.bottom, 20)

                    ForEach(Array(viewModel.content.introParagraphs.enumerated()), id: \.offset) { index, paragraph in
                        HoldYourLiquorBodyParagraphView(text: paragraph)
                            .padding(.bottom, index < viewModel.content.introParagraphs.count - 1 ? 10 : 0)
                    }

                    BasicStandardDrinkHeaderView(title: viewModel.content.habitsSectionTitle)
                        .padding(.top, 20)
                        .padding(.bottom, 20)

                    ModerationBulletListView(items: viewModel.content.habitBulletItems)
                        .padding(.bottom, 20)

                    BasicStandardDrinkHeaderView(title: viewModel.content.rewardsSectionTitle)
                        .padding(.bottom, 20)

                    TryingToQuitCelebrationSectionView(
                        title: viewModel.content.celebrationTitle,
                        milestones: viewModel.content.milestoneItems
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 88)
            }

            BasicKnowledgeCompleteButtonView(
                title: viewModel.completeButtonTitle,
                onTap: viewModel.completeTapped
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(pageBackground.ignoresSafeArea())
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Trying to quit") {
    let viewModel = TryingToQuitViewModel()
    viewModel.applyPreviewState()
    return TryingToQuitView(viewModel: viewModel)
}
#endif
