//
//  QuitSymptomModalTimelineRowView.swift
//  Calmscient
//
//  Timeline dot, connector, and card row (parity with breathing technique steps).
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct QuitSymptomModalTimelineRowView: View {

    let bodyText: String
    let showsConnectorBelow: Bool

    private let timelineColor = Color(hex: "#6E6BB3")
    private let dotSize: CGFloat = 8
    private let connectorWidth: CGFloat = 1.5

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(spacing: 0) {
                Circle()
                    .fill(timelineColor)
                    .frame(width: dotSize, height: dotSize)
                    .padding(.top, 8)

                if showsConnectorBelow {
                    Rectangle()
                        .fill(timelineColor)
                        .frame(width: connectorWidth)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 20)

            QuitSymptomModalTimelineCardView(bodyText: bodyText)
        }
        .padding(.horizontal, 12)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Quit symptom timeline row") {
    QuitSymptomModalTimelineRowView(
        bodyText: "Use a fast-acting nicotine medicine like lozenges or gum to quickly combat cravings",
        showsConnectorBelow: true
    )
    .padding()
}
#endif
