//
//  BreathingTechniqueType1StepsSectionView.swift
//  Calmscient
//
//  Step cards with a single continuous timeline rail and centered dots.
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
private struct StepDotCenterPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]

    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

@available(iOS 16.0, *)
struct BreathingTechniqueType1StepsSectionView: View {

    let steps: [BreathingTechniqueType1StepPresentation]

    @State private var dotCenterYs: [Int: CGFloat] = [:]

    private let timelineColor = Color(hex: "#6E6BB3")
    private let dotSize: CGFloat = 12
    private let lineWidth: CGFloat = 2
    private let railWidth: CGFloat = 20
    private let rowSpacing: CGFloat = 16

    private var lineLeadingOffset: CGFloat {
        (railWidth - lineWidth) / 2
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                HStack(alignment: .center, spacing: 12) {
                    Circle()
                        .fill(timelineColor)
                        .frame(width: dotSize, height: dotSize)
                        .frame(width: railWidth)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: StepDotCenterPreferenceKey.self,
                                    value: [step.id: geometry.frame(in: .named("stepsTimeline")).midY]
                                )
                            }
                        )

                    BreathingTechniqueType1StepCardView(title: step.title, bodyText: step.body)
                }
                .padding(.bottom, index == steps.count - 1 ? 0 : rowSpacing)
            }
        }
        .coordinateSpace(name: "stepsTimeline")
        .onPreferenceChange(StepDotCenterPreferenceKey.self) { dotCenterYs = $0 }
        .overlay(alignment: .topLeading) {
            timelineConnectorLine
        }
    }

    @ViewBuilder
    private var timelineConnectorLine: some View {
        if let firstID = steps.first?.id,
           let lastID = steps.last?.id,
           let topY = dotCenterYs[firstID],
           let bottomY = dotCenterYs[lastID],
           bottomY > topY {
            Rectangle()
                .fill(timelineColor)
                .frame(width: lineWidth, height: bottomY - topY)
                .offset(x: lineLeadingOffset, y: topY)
                .allowsHitTesting(false)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Steps section") {
    BreathingTechniqueType1StepsSectionView(steps: BreathingTechniqueType1PreviewData.sampleSteps())
        .padding()
}
#endif
