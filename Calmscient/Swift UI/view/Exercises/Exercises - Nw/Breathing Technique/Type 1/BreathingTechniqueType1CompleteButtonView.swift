//
//  BreathingTechniqueType1CompleteButtonView.swift
//  Calmscient
//
//  Complete action for the 4-7-8 breathing exercise (enabled near end of video).
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct BreathingTechniqueType1CompleteButtonView: View {

    let title: String
    let isEnabled: Bool
    let action: () -> Void

    private let enabledBackground = Color(red: 0.43, green: 0.42, blue: 0.70)

    var body: some View {
        HStack {
            Spacer()
            Button(action: action) {
                Text(title)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule(style: .continuous)
                            .fill(enabledBackground)
                    )
            }
            .buttonStyle(.plain)
            .disabled(!isEnabled)
            .opacity(isEnabled ? 1 : 0.5)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Complete — disabled") {
    BreathingTechniqueType1CompleteButtonView(title: "Complete".localized, isEnabled: false, action: {})
        .padding()
}

@available(iOS 16.0, *)
#Preview("Complete — enabled") {
    BreathingTechniqueType1CompleteButtonView(title: "Complete".localized, isEnabled: true, action: {})
        .padding()
}
#endif
