//
//  TouchButterflyHowToBottomBarView.swift
//  Calmscient
//
//  Bottom bar with back icon + complete button for the butterfly hug steps.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TouchButterflyHowToBottomBarView: View {

    let completeTitle: String
    let onBack: () -> Void
    let onComplete: () -> Void

    private let controlSide: CGFloat = 41
    private let barHeight: CGFloat = 77
    private let backBackground = Color(hex: "#6E6BB3")

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image("back")
                    .resizable()
                    .scaledToFit()
                    .frame(width: controlSide, height: controlSide)
                    .background(Circle().fill(backBackground))
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)

            Spacer()

            BreathingTechniqueType1CompleteButtonView(
                title: completeTitle,
                isEnabled: true,
                action: onComplete
            )
        }
        .padding(.horizontal, 20)
        .frame(height: barHeight)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .systemBackground))
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Touch butterfly how-to bottom bar") {
    TouchButterflyHowToBottomBarView(
        completeTitle: "Complete",
        onBack: {},
        onComplete: {}
    )
}
#endif

