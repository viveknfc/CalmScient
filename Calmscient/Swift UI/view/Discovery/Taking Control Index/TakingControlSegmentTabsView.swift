//
//  TakingControlSegmentTabsView.swift
//  Calmscient
//
//  Drinking / Smoking top tab selector with purple underline indicator.
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TakingControlSegmentTabsView: View {

    let drinkingTitle: String
    let smokingTitle: String
    @Binding var selectedSegment: TakingControlSegment

    private let brandPurple = LoginDesignSystem.ColorName.primaryGradientTop
    private let inactiveGray = Color(red: 0.65, green: 0.65, blue: 0.68)

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                segmentButton(title: drinkingTitle, segment: .drinking)
                segmentButton(title: smokingTitle, segment: .smoking)
            }
            .padding(.horizontal, 10)

            GeometryReader { proxy in
                let width = proxy.size.width / 2
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(brandPurple)
                    .frame(width: width, height: 3)
                    .offset(x: selectedSegment == .drinking ? 0 : width)
                    .animation(.easeInOut(duration: 0.35), value: selectedSegment)
            }
            .frame(height: 3)
            .padding(.horizontal, 10)
        }
    }

    private func segmentButton(title: String, segment: TakingControlSegment) -> some View {
        Button {
            selectedSegment = segment
        } label: {
            Text(title)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 16))
                .foregroundStyle(selectedSegment == segment ? brandPurple : inactiveGray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Segment tabs — drinking") {
    struct Host: View {
        @State private var segment: TakingControlSegment = .drinking
        var body: some View {
            TakingControlSegmentTabsView(
                drinkingTitle: "Drinking",
                smokingTitle: "Smoking",
                selectedSegment: $segment
            )
        }
    }
    return Host()
}
#endif
