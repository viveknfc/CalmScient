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
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(red: 0.96, green: 0.96, blue: 0.97))
                        .frame(width: 160, height: 88)

                    if let thumbnailURL {
                        AsyncImage(url: thumbnailURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 160, height: 88)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            case .failure, .empty:
                                ProgressView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }

                Text(title)
                    .font(LoginDesignSystem.Typography.lexendMedium(size: 13))
                    .foregroundStyle(LoginDesignSystem.ColorName.titleGray)
                    .lineLimit(2)
                    .frame(width: 160, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
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
                onTap: {}
            )
            HomeDashboardFavoriteTileView(
                title: "Mindful breathing exercise",
                thumbnailURL: URL(string: "https://picsum.photos/321/176"),
                onTap: {}
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    .background(LoginDesignSystem.ColorName.pageBackground)
}
#endif

