//
//  QuitSymptomModalTimelineSectionView.swift
//  Calmscient
//
//  Timeline cards with one continuous vertical rail and centered dots.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
private struct QuitSymptomDotCenterPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]

    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

@available(iOS 16.0, *)
struct QuitSymptomModalTimelineSectionView: View {

    let steps: [String]

    @State private var dotCenterYs: [Int: CGFloat] = [:]

    private let timelineColor = Color(hex: "#6E6BB3")
    private let dotSize: CGFloat = 10
    private let lineWidth: CGFloat = 2
    private let railWidth: CGFloat = 20
    private let rowSpacing: CGFloat = 16

    private var lineLeadingOffset: CGFloat {
        (railWidth - lineWidth) / 2
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .center, spacing: 8) {
                    Circle()
                        .fill(timelineColor)
                        .frame(width: dotSize, height: dotSize)
                        .frame(width: railWidth)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: QuitSymptomDotCenterPreferenceKey.self,
                                    value: [index: geometry.frame(in: .named("quitSymptomTimeline")).midY]
                                )
                            }
                        )

                    QuitSymptomModalTimelineCardView(bodyText: step)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, index == steps.count - 1 ? 0 : rowSpacing)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, 6)
        .coordinateSpace(name: "quitSymptomTimeline")
        .onPreferenceChange(QuitSymptomDotCenterPreferenceKey.self) { dotCenterYs = $0 }
        .overlay(alignment: .topLeading) {
            timelineConnectorLine
        }
    }

    @ViewBuilder
    private var timelineConnectorLine: some View {
        if let firstIndex = steps.indices.first,
           let lastIndex = steps.indices.last,
           let topY = dotCenterYs[firstIndex],
           let bottomY = dotCenterYs[lastIndex],
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
#Preview("Quit symptom timeline section") {
    QuitSymptomModalTimelineSectionView(steps: [
        "Put on a new patch each morning to get a steady level of nicotine.",
        "Use a fast-acting nicotine medicine like lozenges or gum to quickly combat cravings",
        "You can control how often you use the fast-acting medicine, so you won't get more nicotine than you want.",
        "It's OK to start nicotine patches, gum, or lozenges a week or two before you quit smoking.",
    ])
    .padding()
}
#endif
