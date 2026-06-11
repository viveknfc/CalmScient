//
//  MindfulBodyMovementDescriptionView.swift
//  Calmscient
//
//  Description copy for mindful body movement.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MindfulBodyMovementDescriptionView: View {

    let text: String

    var body: some View {
        Text(text)
            .font(LoginDesignSystem.Typography.lexendLight(size: 15))
            .foregroundStyle(Color.primary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Mindful body movement description") {
    MindfulBodyMovementDescriptionView(
        text: "There are many movement routines that invite you to reconnect with your body."
    )
    .padding(.horizontal, 16)
}
#endif
