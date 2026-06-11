//
//  MovementDanceDescriptionView.swift
//  Calmscient
//
//  Description copy for movement: dance.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MovementDanceDescriptionView: View {

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
#Preview("Movement dance description") {
    MovementDanceDescriptionView(
        text: "Moving your body to music can be a fun and fast way to shift your state and reconnect with your body, rhythm and expression."
    )
    .padding(.horizontal, 16)
}
#endif
