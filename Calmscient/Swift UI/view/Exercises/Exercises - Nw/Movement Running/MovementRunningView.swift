//
//  MovementRunningView.swift
//  Calmscient
//
//  SwiftUI movement: running detail (parity with legacy `MovementRunning`).
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MovementRunningView: View {

    @ObservedObject var viewModel: MovementRunningViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                MovementRunningHeaderView(
                    heroImageName: MovementRunningPresentation.heroImageName,
                    favoriteImageName: viewModel.favoriteImageName,
                    onFavoriteTap: viewModel.toggleFavorite
                )

                MovementRunningDescriptionView(text: viewModel.descriptionText)
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
#Preview("Movement running") {
    let viewModel = MovementRunningViewModel()
    viewModel.applyPreviewState()
    return MovementRunningView(viewModel: viewModel)
}
#endif
