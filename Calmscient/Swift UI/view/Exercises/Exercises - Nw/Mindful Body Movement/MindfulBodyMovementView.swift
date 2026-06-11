//
//  MindfulBodyMovementView.swift
//  Calmscient
//
//  SwiftUI mindful body movement detail (parity with legacy `MindfulBodyMovement`).
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MindfulBodyMovementView: View {

    @ObservedObject var viewModel: MindfulBodyMovementViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                MindfulBodyMovementHeaderView(
                    heroImageName: MindfulBodyMovementPresentation.heroImageName,
                    favoriteImageName: viewModel.favoriteImageName,
                    onFavoriteTap: viewModel.toggleFavorite
                )

                MindfulBodyMovementDescriptionView(text: viewModel.descriptionText)
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
#Preview("Mindful body movement") {
    let viewModel = MindfulBodyMovementViewModel()
    viewModel.applyPreviewState()
    return MindfulBodyMovementView(viewModel: viewModel)
}
#endif
