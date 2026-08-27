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
    /// Bundled artwork for favourites the server sends no usable thumbnail for.
    let fallbackImageName: ([String: Any]) -> String?
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
                    // Top-aligned so every thumbnail and every title starts on the same
                    // line. The default centring made a tile with a wrapping title float
                    // upwards relative to its neighbours.
                    HStack(alignment: .top, spacing: 15) {
                        ForEach(Array(favorites.enumerated()), id: \.offset) { _, item in
                            HomeDashboardFavoriteTileView(
                                title: titleForFavorite(item),
                                thumbnailURL: thumbnailURL(item),
                                fallbackImageName: fallbackImageName(item),
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
        fallbackImageName: { _ in nil },
        onFavoriteTap: { _ in }
    )
    .background(LoginDesignSystem.ColorName.pageBackground)
}

@available(iOS 16.0, *)
#Preview("Favorites section (with items)") {
    let sample: [[String: Any]] = [
        ["title": "Mindfulness - what is it?", "thumbnailUrl": "https://picsum.photos/320/176"],
        ["title": "4–7–8 Breathing exercise", "thumbnailUrl": "https://picsum.photos/321/176"],
        // An exercise favourite the backend sent no thumbnail for.
        ["title": "Progressive muscle relaxation", "isFromExercises": 1, "screenCode": 9],
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
        fallbackImageName: { dict in
            guard (dict["isFromExercises"] as? Int) == 1,
                  let code = dict["screenCode"] as? Int,
                  let exercise = ExcercisesTypeEnum(rawValue: code)
            else { return nil }
            return exercise.favoriteThumbnailAssetName
        },
        onFavoriteTap: { _ in }
    )
    .background(LoginDesignSystem.ColorName.pageBackground)
}
#endif

