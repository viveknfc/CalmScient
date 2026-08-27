//
//  HomeDashboardFavoriteTileView.swift
//  Calmscient
//
//  Vivek
//  14 May 2026
//
import SwiftUI

@available(iOS 16.0, *)
struct HomeDashboardFavoriteTileView: View {

    let title: String
    let thumbnailURL: URL?
    /// Bundled artwork to draw when the remote thumbnail is absent or cannot load.
    /// `nil` for favourites the app ships no image for (videos, articles).
    let fallbackImageName: String?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(red: 0.96, green: 0.96, blue: 0.97))
                        .frame(width: 160, height: 88)

                    // Drawn underneath, so a favourite the app has art for is never blank
                    // and never spins. A remote thumbnail simply covers it on success.
                    if let fallbackImageName {
                        tileImage(Image(fallbackImageName))
                    }

                    if let thumbnailURL {
                        AsyncImage(url: thumbnailURL) { phase in
                            switch phase {
                            case .success(let image):
                                tileImage(image)
                            case .empty:
                                // Still in flight — but only worth a spinner when there is
                                // nothing behind it to look at.
                                if fallbackImageName == nil {
                                    ProgressView()
                                } else {
                                    EmptyView()
                                }
                            case .failure:
                                // A thumbnail that cannot load is a *finished* phase, not a
                                // pending one. Sharing this case with `.empty` left the
                                // spinner turning forever on any favourite whose
                                // `thumbnailUrl` 404s or is not a loadable absolute URL.
                                // Falling through leaves the bundled art — or the plain
                                // tile — visible, matching every other `AsyncImage` in the
                                // app (`ScreeningListCardView`, `CoursesChapterCardView`, …).
                                EmptyView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }

                Text(title)
                    .font(LoginDesignSystem.Typography.lexendMedium(size: 13))
                    .foregroundStyle(LoginDesignSystem.ColorName.titleGray)
                    .multilineTextAlignment(.center)
                    // `reservesSpace` keeps the two-line box even for a one-line title, so
                    // every tile is exactly the same height. Without it a wrapping title
                    // made its tile taller than its neighbours, and the `HStack`'s centring
                    // then pushed that whole tile up — which is why "Touch and the
                    // butterfly hug" sat higher than the cards beside it.
                    .lineLimit(2, reservesSpace: true)
                    .frame(width: 160, alignment: .center)
            }
        }
        .buttonStyle(.plain)
    }

    /// One place for the tile's image geometry, so the bundled art and the remote
    /// thumbnail can never be framed or clipped differently.
    private func tileImage(_ image: Image) -> some View {
        image
            .resizable()
            .scaledToFill()
            .frame(width: 160, height: 88)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Favorite tile") {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 15) {
            HomeDashboardFavoriteTileView(
                title: "What happens to your brain when you drink?",
                thumbnailURL: URL(string: "https://picsum.photos/320/176"),
                fallbackImageName: nil,
                onTap: {}
            )
            HomeDashboardFavoriteTileView(
                title: "Mindful breathing exercise",
                thumbnailURL: URL(string: "https://picsum.photos/321/176"),
                fallbackImageName: "breathingTechnique",
                onTap: {}
            )
            // No remote thumbnail — the bundled exercise art carries the tile.
            HomeDashboardFavoriteTileView(
                title: "Progressive muscle relaxation",
                thumbnailURL: nil,
                fallbackImageName: "progressiveWithHeadset",
                onTap: {}
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    .background(LoginDesignSystem.ColorName.pageBackground)
}
#endif

