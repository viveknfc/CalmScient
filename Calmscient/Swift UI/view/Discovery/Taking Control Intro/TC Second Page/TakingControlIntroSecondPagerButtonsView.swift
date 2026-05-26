//
//  TakingControlIntroSecondPagerButtonsView.swift
//  Calmscient
//
//  Floating previous / next circular controls (parity with storyboard actions).
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TakingControlIntroSecondPagerButtonsView: View {
    let onPrevious: () -> Void
    let onNext: () -> Void

    private let circleSize: CGFloat = 38

    var body: some View {
        HStack(spacing: 28) {
            pagerCircle(systemName: "backward", action: onPrevious)
            Spacer()
            pagerCircle(systemName: "forwardArrow", action: onNext)
        }
        .padding(.horizontal, 38)
        .padding(.vertical, 12)
    }

    private func pagerCircle(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName)
                .frame(width: circleSize, height: circleSize)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Pager buttons") {
    ZStack {
        Color("AppBackGroundColor").ignoresSafeArea()
        VStack {
            Spacer()
            TakingControlIntroSecondPagerButtonsView(onPrevious: {}, onNext: {})
        }
    }
}
#endif
