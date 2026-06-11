//
//  BreathingTechniqueType1StepRowView.swift
//  Calmscient
//
//  Single step row (circle + card). Prefer `BreathingTechniqueType1StepsSectionView` for the full timeline.
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct BreathingTechniqueType1StepRowView: View {

    let step: BreathingTechniqueType1StepPresentation

    private let timelineColor = Color(hex: "#6E6BB3")
    private let dotSize: CGFloat = 12
    private let railWidth: CGFloat = 20

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Circle()
                .fill(timelineColor)
                .frame(width: dotSize, height: dotSize)
                .frame(width: railWidth)

            BreathingTechniqueType1StepCardView(title: step.title, bodyText: step.body)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Step row") {
    BreathingTechniqueType1StepRowView(
        step: BreathingTechniqueType1PreviewData.sampleSteps()[0]
    )
    .padding()
}
#endif
