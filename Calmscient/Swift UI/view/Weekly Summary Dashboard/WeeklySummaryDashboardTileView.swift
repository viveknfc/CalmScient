//
//  WeeklySummaryDashboardTileView.swift
//  Calmscient
//
//  Two-column grid tile with full-bleed image and bottom title (parity with `WeeklySummaryDashboardCell`).
//
//  Vivek
//  17 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct WeeklySummaryDashboardTileView: View {

    let title: String
    let imageName: String
    let onTap: () -> Void

    static let cornerRadius: CGFloat = 5

    private var corner: CGFloat { Self.cornerRadius }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                Group {
                    if let ui = UIImage(named: imageName) {
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Rectangle()
                            .fill(LoginDesignSystem.ColorName.pageBackground)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

                LinearGradient(
                    colors: [
                        Color.black.opacity(0.0),
                        Color.black.opacity(0.72),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0.35),
                    endPoint: .bottom
                )
                .allowsHitTesting(false)

                Text(title)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Mood summary tile") {
    WeeklySummaryDashboardTileView(
        title: "Summary of mood",
        imageName: "SummaryOfMood",
        onTap: {}
    )
    .frame(width: 180, height: 125)
    .background(LoginDesignSystem.ColorName.pageBackground)
}

@available(iOS 16.0, *)
#Preview("Sleep summary tile") {
    WeeklySummaryDashboardTileView(
        title: "Summary of sleep",
        imageName: "SummaryOfSleep",
        onTap: {}
    )
    .frame(width: 180, height: 125)
    .background(LoginDesignSystem.ColorName.pageBackground)
}
#endif
