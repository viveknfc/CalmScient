//
//  BreathingTechniqueHeroImageView.swift
//  Calmscient
//
//  Hero image for the breathing technique index screen.
//
//  Vivek
//  20 May 2026
//

import SwiftUI

struct BreathingTechniqueHeroImageView: View {

    let imageName: String

    private let aspectRatio: CGFloat = 393.0 / 269.0

    var body: some View {
        Group {
            if let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Color(red: 0.92, green: 0.92, blue: 0.95)
            }
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipped()
    }
}

#if DEBUG
#Preview("Breathing technique hero") {
    BreathingTechniqueHeroImageView(imageName: "breathingTechnique")
}
#endif
