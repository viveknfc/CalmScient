//
//  MindfulnessBottomBarView.swift
//  Calmscient
//
//  Bottom back / forward / complete controls (parity with legacy storyboard bar).
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MindfulnessBottomBarView: View {

    let showsBack: Bool
    let showsForward: Bool
    let showsComplete: Bool
    let completeTitle: String
    let onBack: () -> Void
    let onForward: () -> Void
    let onComplete: () -> Void

    private let controlSide: CGFloat = 41
    private let barHeight: CGFloat = 77

    var body: some View {
        HStack {
            if showsBack {
                stepControlButton(imageName: "back", action: onBack)
            } else {
                Color.clear
                    .frame(width: controlSide, height: controlSide)
            }

            Spacer()

            if showsComplete {
                BreathingTechniqueType1CompleteButtonView(
                    title: completeTitle,
                    isEnabled: true,
                    action: onComplete
                )
            } else if showsForward {
                stepControlButton(imageName: "front", action: onForward)
            }
        }
        .padding(.horizontal, 20)
        .frame(height: barHeight)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .systemBackground))
    }

    private func stepControlButton(imageName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: controlSide, height: controlSide)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Mindfulness bottom — middle step") {
    MindfulnessBottomBarView(
        showsBack: true,
        showsForward: true,
        showsComplete: false,
        completeTitle: "Complete",
        onBack: {},
        onForward: {},
        onComplete: {}
    )
}

@available(iOS 16.0, *)
#Preview("Mindfulness bottom — final step") {
    MindfulnessBottomBarView(
        showsBack: true,
        showsForward: false,
        showsComplete: true,
        completeTitle: "Complete",
        onBack: {},
        onForward: {},
        onComplete: {}
    )
}
#endif
