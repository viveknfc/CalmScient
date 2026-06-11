//
//  HomeDashboardFavoritesSectionView.swift
//  Calmscient
//
//  Vivek
//  14 May 2026
//
import SwiftUI

@available(iOS 16.0, *)
struct HomeDashboardFavoritesSectionView: View {

    let title: String
    let emptyMessage: String
    let favorites: [[String: Any]]
    let titleForFavorite: ([String: Any]) -> String
    let thumbnailURL: ([String: Any]) -> URL?
    let onFavoriteTap: ([String: Any]) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(LoginDesignSystem.Typography.lexendMedium(size: 18))
                .foregroundStyle(LoginDesignSystem.ColorName.titleGray)
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 12)

            if favorites.isEmpty {
                VStack {
                    Spacer()
                    
                    Text(emptyMessage)
                        .font(LoginDesignSystem.Typography.lexendMedium(size: 15))
                        .foregroundStyle(LoginDesignSystem.ColorName.purple.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 24)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(Array(favorites.enumerated()), id: \.offset) { _, item in
                            HomeDashboardFavoriteTileView(
                                title: titleForFavorite(item),
                                thumbnailURL: thumbnailURL(item),
                                onTap: { onFavoriteTap(item) }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 6)
                }
            }
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Favorites section (empty)") {
    HomeDashboardFavoritesSectionView(
        title: "My favorites",
        emptyMessage: "No favorites found for this patient",
        favorites: [],
        titleForFavorite: { ($0["title"] as? String) ?? "" },
        thumbnailURL: { _ in nil },
        onFavoriteTap: { _ in }
    )
    .background(LoginDesignSystem.ColorName.pageBackground)
}

@available(iOS 16.0, *)
#Preview("Favorites section (with items)") {
    let sample: [[String: Any]] = [
        ["title": "Mindfulness - what is it?", "thumbnailUrl": "https://picsum.photos/320/176"],
        ["title": "4–7–8 Breathing exercise", "thumbnailUrl": "https://picsum.photos/321/176"],
    ]

    return HomeDashboardFavoritesSectionView(
        title: "My favorites",
        emptyMessage: "No favorites found for this patient",
        favorites: sample,
        titleForFavorite: { ($0["title"] as? String) ?? "" },
        thumbnailURL: { dict in
            guard let s = dict["thumbnailUrl"] as? String else { return nil }
            return URL(string: s)
        },
        onFavoriteTap: { _ in }
    )
    .background(LoginDesignSystem.ColorName.pageBackground)
}
#endif

