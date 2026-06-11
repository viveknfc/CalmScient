//
//  MyDrinkingHabitForwardFabView.swift
//  Calmscient
//
//  Forward navigation FAB (parity with storyboard `forwardArrow` button).
//
//  Vivek
//  25 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MyDrinkingHabitForwardFabView: View {

    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        HStack {
            Spacer()
            Button(action: action) {
                Image("forwardArrow")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(accessibilityLabel))
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Forward FAB") {
    ZStack(alignment: .bottomTrailing) {
        Color("AppBackGroundColor").ignoresSafeArea()
        MyDrinkingHabitForwardFabView(accessibilityLabel: "Next", action: {})
            .padding(.trailing, 20)
            .padding(.bottom, 20)
    }
}
#endif
