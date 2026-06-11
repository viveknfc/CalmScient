//
//  HandOverYourHeartView.swift
//  Calmscient
//
//  SwiftUI hand over your heart (parity with legacy `HandOverYourHeart`).
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct HandOverYourHeartView: View {

    @ObservedObject var viewModel: HandOverYourHeartViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HandOverYourHeartHeaderView(
                    heroImageName: HandOverYourHeartPresentation.heroImageName,
                    favoriteImageName: viewModel.favoriteImageName,
                    onFavoriteTap: viewModel.toggleFavorite
                )

                Text(viewModel.howToTitle)
                    .font(LoginDesignSystem.Typography.lexendLight(size: 19))
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal, 20)
                    .padding(.top, 24)

                HandOverYourHeartBulletStepsView(steps: viewModel.bulletSteps)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
            }
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                BreathingTechniqueType1CompleteButtonView(
                    title: "Complete".localized,
                    isEnabled: true,
                    action: viewModel.completeTapped
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground).ignoresSafeArea())
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Hand over your heart") {
    let viewModel = HandOverYourHeartViewModel()
    viewModel.applyPreviewState()
    return HandOverYourHeartView(viewModel: viewModel)
}
#endif
