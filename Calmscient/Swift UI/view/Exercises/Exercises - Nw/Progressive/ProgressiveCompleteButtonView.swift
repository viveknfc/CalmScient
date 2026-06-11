//
//  ProgressiveCompleteButtonView.swift
//  Calmscient
//
//  Trailing complete action for the progressive exercise.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ProgressiveCompleteButtonView: View {

    let title: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            Spacer()
            BreathingTechniqueType1CompleteButtonView(
                title: title,
                isEnabled: isEnabled,
                action: action
            )
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Progressive complete") {
    ProgressiveCompleteButtonView(title: "Complete".localized, isEnabled: false, action: {})
        .padding()
}
#endif
