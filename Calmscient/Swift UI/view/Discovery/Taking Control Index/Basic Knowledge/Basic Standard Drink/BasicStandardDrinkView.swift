//
//  BasicStandardDrinkView.swift
//  Calmscient
//
//  SwiftUI standard drink education screen (parity with legacy `BasicStandardDrink`).
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct BasicStandardDrinkView: View {

    @ObservedObject var viewModel: BasicStandardDrinkViewModel

    private let pageBackground = Color("AppBackGroundColor")

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    BasicStandardDrinkHeaderView(title: viewModel.headerTitle)

                    BasicStandardDrinkIntroTextView(introText: viewModel.introAttributedText)

                    BasicStandardDrinkCarouselView(
                        item: viewModel.currentCarouselItem,
                        canShowPrevious: viewModel.canShowPreviousCarouselItem,
                        canShowNext: viewModel.canShowNextCarouselItem,
                        onPrevious: viewModel.showPreviousCarouselItem,
                        onNext: viewModel.showNextCarouselItem
                    )

                    BasicStandardDrinkBodyTextView(text: viewModel.bodyDescriptionText)
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
        .overlay {
            if viewModel.isLoading || viewModel.isCompleting {
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
#Preview("Standard drink screen") {
    let viewModel = BasicStandardDrinkViewModel()
    viewModel.applyPreviewState(
        items: StandardDrinkCarouselItemPresentation.previewItems(),
        currentIndex: 0
    )
    return BasicStandardDrinkView(viewModel: viewModel)
}
#endif
