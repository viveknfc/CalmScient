//
//  TouchButterflyIntroView.swift
//  Calmscient
//
//  SwiftUI intro for touch and the butterfly hug (parity with `TouchAndButterFly2`).
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TouchButterflyIntroView: View {

    @ObservedObject var viewModel: TouchButterflyHugViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    TouchButterflyIntroHeaderView(
                        heroImageName: TouchButterflyHugPresentation.introHeroImageName,
                        favoriteImageName: viewModel.favoriteImageName,
                        onFavoriteTap: viewModel.toggleFavorite
                    )

                    Text(viewModel.introDescription)
                        .font(LoginDesignSystem.Typography.lexendLight(size: 15))
                        .foregroundStyle(Color.primary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                }
                .padding(.bottom, 76)
            }
            .scrollIndicators(.hidden)

            TouchButterflyForwardBarView(
                iconName: TouchButterflyHugPresentation.forwardIconName,
                onForward: viewModel.openHowTo
            )
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground).ignoresSafeArea())
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Touch butterfly intro") {
    let viewModel = TouchButterflyHugViewModel()
    viewModel.applyPreviewState()
    return TouchButterflyIntroView(viewModel: viewModel)
}
#endif

