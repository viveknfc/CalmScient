//
//  MindfulWalkingHeaderView.swift
//  Calmscient
//
//  Question + hero image header with favorite overlay.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MindfulWalkingHeaderView: View {

    let questionTitle: String
    let heroImageName: String
    let favoriteImageName: String
    let onFavoriteTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(questionTitle)
                .font(LoginDesignSystem.Typography.lexendLight(size: 15))
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
                .padding(.top, 20)

            ZStack(alignment: .topTrailing) {
                Image(heroImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 269)
                    .clipped()
                    .accessibilityHidden(true)

                Button(action: onFavoriteTap) {
                    Image(favoriteImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 41, height: 41)
                }
                .buttonStyle(.plain)
                .padding(.top, 20)
                .padding(.trailing, 20)
            }
            .padding(.top, 20)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Mindful walking header") {
    MindfulWalkingHeaderView(
        questionTitle: "What are the benefits of mindful walking?",
        heroImageName: "mindful",
        favoriteImageName: "fav",
        onFavoriteTap: {}
    )
}
#endif
