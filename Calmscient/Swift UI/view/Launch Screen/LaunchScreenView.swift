//
//  LaunchScreenView.swift
//  Calmscient
//
//  SwiftUI splash: white background, centered looping logo GIF.
//
//  Vivek
//  27 May 2026
//
import SwiftUI

@available(iOS 16.0, *)
struct LaunchScreenView: View {

    /// Storyboard logo proportions (280 × 140).
    private let logoAspectRatio: CGFloat = 2

    var body: some View {
        GeometryReader { geometry in
            let size = fittedLogoSize(in: geometry.size)

            ZStack {
                Color.white
                    .ignoresSafeArea()

                LaunchGifRepresentable()
                    .frame(width: size.width, height: size.height)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

    /// Centers the logo and scales it down so it fits the screen with side padding.
    private func fittedLogoSize(in containerSize: CGSize) -> CGSize {
        let horizontalPadding: CGFloat = 56
        let maxHeightFraction: CGFloat = 0.22

        let maxWidth = max(containerSize.width - horizontalPadding, 0)
        let maxHeight = max(containerSize.height * maxHeightFraction, 0)

        var width = min(maxWidth, 280)
        var height = width / logoAspectRatio

        if height > maxHeight {
            height = maxHeight
            width = height * logoAspectRatio
        }

        return CGSize(width: max(width, 0), height: max(height, 0))
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Launch screen") {
    LaunchScreenView()
}
#endif
