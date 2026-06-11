//
//  MindfulnessFavoriteToolbarView.swift
//  Calmscient
//
//  Bell and favorite controls shown on the final mindfulness step.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MindfulnessFavoriteToolbarView: View {

    let favoriteImageName: String
    let onFavoriteTap: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Spacer()
            Image("bell")
                .resizable()
                .scaledToFit()
                .frame(width: 41, height: 41)
                .accessibilityHidden(true)

            Button(action: onFavoriteTap) {
                Image(favoriteImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 41, height: 41)
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(.isButton)
        }
        .frame(height: 41)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Mindfulness favorite toolbar") {
    MindfulnessFavoriteToolbarView(favoriteImageName: "fav", onFavoriteTap: {})
        .padding(.horizontal, 20)
}
#endif
