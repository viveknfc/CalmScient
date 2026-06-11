//
//  ConsequenceIntroBodyTextView.swift
//  Calmscient
//
//  Introductory body copy for the consequences index screen.
//
//  Vivek
//  25 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ConsequenceIntroBodyTextView: View {

    let text: String

    private let bodyFont = LoginDesignSystem.Typography.lexendLight(size: 15)
    private let bodyColor = Color("424242Color")

    var body: some View {
        Text(text)
            .font(bodyFont)
            .foregroundStyle(bodyColor)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Consequence intro body") {
    ConsequenceIntroBodyTextView(text: "consequences_intro_body".localized)
        .padding(.horizontal, 20)
}
#endif
