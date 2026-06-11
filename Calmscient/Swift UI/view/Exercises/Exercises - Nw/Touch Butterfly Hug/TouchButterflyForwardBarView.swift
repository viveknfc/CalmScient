//
//  TouchButterflyForwardBarView.swift
//  Calmscient
//
//  Bottom forward control for the intro screen.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TouchButterflyForwardBarView: View {

    let iconName: String
    let onForward: () -> Void

    private let barHeight: CGFloat = 56
    private let iconSide: CGFloat = 41

    var body: some View {
        HStack {
            Spacer()
            Button(action: onForward) {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSide, height: iconSide)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 20)
        }
        .frame(height: barHeight)
        .frame(maxWidth: .infinity)
        .background(Color.clear)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Touch butterfly forward bar") {
    TouchButterflyForwardBarView(iconName: "front", onForward: {})
        .padding()
}
#endif

