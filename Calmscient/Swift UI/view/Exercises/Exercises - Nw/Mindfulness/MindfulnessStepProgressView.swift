//
//  MindfulnessStepProgressView.swift
//  Calmscient
//
//  Step progress rail image for the mindfulness exercise.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MindfulnessStepProgressView: View {

    let imageName: String

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .frame(height: 28)
            .accessibilityHidden(true)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Mindfulness progress — step 1") {
    MindfulnessStepProgressView(imageName: "step1")
        .padding(.horizontal, 20)
}
#endif
