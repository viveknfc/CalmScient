//
//  TouchButterflyIntroHeaderView.swift
//  Calmscient
//
//  Hero image + favorite button header.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TouchButterflyIntroHeaderView: View {

    let heroImageName: String
    let favoriteImageName: String
    let onFavoriteTap: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(heroImageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 268)
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
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Touch butterfly intro header") {
    TouchButterflyIntroHeaderView(
        heroImageName: "touchAndButterfly",
        favoriteImageName: "fav",
        onFavoriteTap: {}
    )
}
#endif

