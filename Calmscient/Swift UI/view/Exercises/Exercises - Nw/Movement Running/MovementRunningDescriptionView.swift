//
//  MovementRunningDescriptionView.swift
//  Calmscient
//
//  Description copy for movement: running.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MovementRunningDescriptionView: View {

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
#Preview("Movement running description") {
    MovementRunningDescriptionView(
        text: "It’s not easy to move when you have a shutdown or are feeling numb. Running can quickly shift you out of the shutdown state and re-energize you."
    )
    .padding(.horizontal, 16)
}
#endif
