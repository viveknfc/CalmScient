//
//  TakingIntroLastFabBackButton.swift
//  Calmscient
//
//  Floating circular back control above the tab bar (parity with storyboard FAB).
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TakingIntroLastFabBackButton: View {
    let action: () -> Void

    private let circleSize: CGFloat = 40
    private let fill = Color(red: 99 / 255, green: 107 / 255, blue: 179 / 255)

    var body: some View {
        Button(action: action) {
            Image("backward")
                .frame(width: circleSize, height: circleSize)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(TakingIntroLastLocalization.fabBackAccessibility.localized))
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("FAB back") {
    ZStack(alignment: .bottomLeading) {
        Color("AppBackGroundColor").ignoresSafeArea()
        TakingIntroLastFabBackButton(action: {})
            .padding(24)
    }
}
#endif
