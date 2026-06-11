//
//  MindfulBodyMovementHeaderView.swift
//  Calmscient
//
//  Hero image with favorite overlay for mindful body movement.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MindfulBodyMovementHeaderView: View {

    let heroImageName: String
    let favoriteImageName: String
    let onFavoriteTap: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(heroImageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 204)
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
            .padding(.trailing, 16)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Mindful body movement header") {
    MindfulBodyMovementHeaderView(
        heroImageName: "butterflyLady",
        favoriteImageName: "fav",
        onFavoriteTap: {}
    )
}
#endif
