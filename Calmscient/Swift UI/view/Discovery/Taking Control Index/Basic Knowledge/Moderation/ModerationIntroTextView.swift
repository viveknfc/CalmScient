//
//  ModerationIntroTextView.swift
//  Calmscient
//
//  Introductory copy for the moderation screen.
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ModerationIntroTextView: View {

    let text: String

    private let bodyFont = LoginDesignSystem.Typography.lexendLight(size: 14)
    private let bodyColor = Color("424242Color")

    var body: some View {
        Text(text)
            .font(bodyFont)
            .foregroundStyle(bodyColor)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: false)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Moderation intro") {
    ModerationIntroTextView(text: "moderation_intro_text".localized)
        .padding(.horizontal, 20)
}
#endif
