//
//  HomeDashboardView.swift
//  Calmscient
//
//  SwiftUI home tab dashboard (parity with `HomeTabDashboardViewController`).
//
//  Vivek
//  14 May 2026
//
import SwiftUI

@available(iOS 16.0, *)
struct HomeDashboardView: View {

    @ObservedObject var viewModel: HomeDashboardViewModel

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HomeDashboardHeaderView(
                    firstName: viewModel.firstName,
                    onProfileTap: { viewModel.openProfile() }
                )
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 20)

                VStack(spacing: 14) {
                    ForEach(Array(viewModel.menuRows.enumerated()), id: \.offset) { index, row in
                        HomeDashboardMenuCardView(
                            title: row.title,
                            imageName: row.imageName,
                            onTap: { viewModel.openMenuRow(at: index) }
                        )

                        // "Health Metrics" sits right after "Mental wellbeing
                        // tracker" (index 2), as the last menu item.
                        if index == 2 {
                            HomeDashboardMenuCardView(
                                title: "Health Metrics".localized,
                                imageName: "heart.text.square.fill",
                                onTap: { viewModel.openHealthMetrics() }
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)

                HomeDashboardFavoritesSectionView(
                    title: viewModel.myFavoritesSectionTitle,
                    emptyMessage: viewModel.emptyFavoritesMessage,
                    favorites: viewModel.favorites,
                    titleForFavorite: { viewModel.localizedFavoriteTitle(for: $0) },
                    thumbnailURL: { viewModel.thumbnailURL(for: $0) },
                    onFavoriteTap: { viewModel.openFavorite($0) }
                )
                
                Spacer()

                if PatientLanguagePreference.shouldShowNeedToTalkButton() {
                    LoginGradientButton(title: viewModel.needToTalkButtonTitle) {
                        viewModel.openNeedToTalk()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .frame(minHeight: proxy.size.height, alignment: .top)
            .frame(maxWidth: .infinity)
            }
            .refreshable { await viewModel.refresh() }
        }
        .background(LoginDesignSystem.ColorName.pageBackground.ignoresSafeArea())
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Home dashboard") {
    // Simple preview without touching singletons (interactive behaviors not required in preview).
    HomeDashboardView(viewModel: HomeDashboardViewModel())
}
#endif
