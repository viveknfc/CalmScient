//
//  MindfulnessIllustrationView.swift
//  Calmscient
//
//  Step illustration for the mindfulness exercise.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MindfulnessIllustrationView: View {

    let imageName: String
    let fit: MindfulnessIllustrationFit

    private let illustrationHeight: CGFloat = 376

    var body: some View {
        Image(imageName)
            .resizable()
            .modifier(IllustrationFitModifier(fit: fit))
            .frame(maxWidth: .infinity)
            .frame(height: illustrationHeight)
            .clipped()
            .accessibilityHidden(true)
    }
}

@available(iOS 16.0, *)
private struct IllustrationFitModifier: ViewModifier {
    let fit: MindfulnessIllustrationFit

    func body(content: Content) -> some View {
        switch fit {
        case .aspectFit:
            content.scaledToFit()
        case .aspectFill:
            content.scaledToFill()
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Mindfulness illustration — step 1") {
    MindfulnessIllustrationView(imageName: "stpe1_img", fit: .aspectFit)
        .padding(.horizontal, 20)
}
#endif
