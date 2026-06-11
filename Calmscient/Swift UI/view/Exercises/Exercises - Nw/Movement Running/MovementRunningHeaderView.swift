//
//  MovementRunningHeaderView.swift
//  Calmscient
//
//  Hero image with favorite overlay for movement: running.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MovementRunningHeaderView: View {

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
#Preview("Movement running header") {
    MovementRunningHeaderView(
        heroImageName: "running",
        favoriteImageName: "fav",
        onFavoriteTap: {}
    )
}
#endif
