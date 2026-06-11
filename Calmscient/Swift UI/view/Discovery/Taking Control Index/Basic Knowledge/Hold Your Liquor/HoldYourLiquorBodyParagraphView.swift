//
//  HoldYourLiquorBodyParagraphView.swift
//  Calmscient
//
//  Body copy paragraph for the hold-your-liquor screen.
//
//  Vivek
//  25 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct HoldYourLiquorBodyParagraphView: View {

    let text: String

    private let textColor = Color("424242Color")

    var body: some View {
        Text(text)
            .font(LoginDesignSystem.Typography.lexendLight(size: 14))
            .foregroundStyle(textColor)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Hold your liquor paragraph") {
    HoldYourLiquorBodyParagraphView(text: "hold_your_liquor_body_paragraph_1".localized)
        .padding(.horizontal, 20)
}
#endif
