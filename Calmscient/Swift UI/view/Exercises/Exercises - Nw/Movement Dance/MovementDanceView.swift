//
//  MovementDanceView.swift
//  Calmscient
//
//  SwiftUI movement: dance detail (parity with legacy `MovementDance`).
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MovementDanceView: View {

    @ObservedObject var viewModel: MovementDanceViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                MovementDanceHeaderView(
                    heroImageName: MovementDancePresentation.heroImageName,
                    favoriteImageName: viewModel.favoriteImageName,
                    onFavoriteTap: viewModel.toggleFavorite
                )

                MovementDanceDescriptionView(text: viewModel.descriptionText)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
            }
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                BreathingTechniqueType1CompleteButtonView(
                    title: viewModel.completeButtonTitle,
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
#Preview("Movement dance") {
    let viewModel = MovementDanceViewModel()
    viewModel.applyPreviewState()
    return MovementDanceView(viewModel: viewModel)
}
#endif
