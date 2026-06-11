//
//  ProgressiveEqualizerView.swift
//  Calmscient
//
//  Equalizer bar with tinted playback progress overlay.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ProgressiveEqualizerView: View {

    let imageName: String
    let progress: CGFloat

    private let barColor = Color(hex: "#F48383")

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityHidden(true)

                barColor
                    .frame(width: proxy.size.width * max(0, min(1, progress)))
                    .mask(
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    )
                    .allowsHitTesting(false)
            }
        }
        .frame(height: 54)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Progressive equalizer") {
    ProgressiveEqualizerView(imageName: "emptyEqualizer", progress: 0.45)
        .padding(.horizontal, 30)
}
#endif
