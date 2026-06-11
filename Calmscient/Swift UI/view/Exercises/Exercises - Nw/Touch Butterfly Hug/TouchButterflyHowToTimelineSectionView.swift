//
//  TouchButterflyHowToTimelineSectionView.swift
//  Calmscient
//
//  Timeline cards for butterfly hug instructions (matches QuitSymptom timeline styling).
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
private struct TouchButterflyDotCenterPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]

    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

@available(iOS 16.0, *)
struct TouchButterflyHowToTimelineSectionView: View {

    let steps: [TouchButterflyHowToStep]

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
            ForEach(steps) { step in
                HStack(alignment: .center, spacing: 8) {
                    Circle()
                        .fill(timelineColor)
                        .frame(width: dotSize, height: dotSize)
                        .frame(width: railWidth)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: TouchButterflyDotCenterPreferenceKey.self,
                                    value: [step.id: geometry.frame(in: .named("touchButterflyTimeline")).midY]
                                )
                            }
                        )

                    TouchButterflyHowToCardView(
                        text: step.textKey.localized,
                        imageName: step.imageName
                    )
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, step.id == steps.last?.id ? 0 : rowSpacing)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, 6)
        .coordinateSpace(name: "touchButterflyTimeline")
        .onPreferenceChange(TouchButterflyDotCenterPreferenceKey.self) { dotCenterYs = $0 }
        .overlay(alignment: .topLeading) {
            timelineConnectorLine
        }
    }

    @ViewBuilder
    private var timelineConnectorLine: some View {
        if let first = steps.first?.id,
           let last = steps.last?.id,
           let topY = dotCenterYs[first],
           let bottomY = dotCenterYs[last],
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
#Preview("Touch butterfly timeline") {
    TouchButterflyHowToTimelineSectionView(steps: TouchButterflyHugPresentation.howToSteps)
        .padding(.horizontal, 20)
}
#endif

