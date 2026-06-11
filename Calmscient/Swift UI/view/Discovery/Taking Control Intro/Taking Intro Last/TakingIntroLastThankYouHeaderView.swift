//
//  TakingIntroLastThankYouHeaderView.swift
//  Calmscient
//
//  Top thank-you block with mixed typography (parity with `TakingIntroLastVC` label1).
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TakingIntroLastThankYouHeaderView: View {
    let attributedText: AttributedString

    var body: some View {
        Text(attributedText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .foregroundStyle(.primary)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Thank you header") {
    let heading = LoginDesignSystem.Typography.lexendMedium(size: 16)
    let body = LoginDesignSystem.Typography.lexendLight(size: 14)
    let attr = TakingIntroLastPresentation.makeThankYouAttributedText(
        fullText: "Thank you for taking the test.\n\nBeing honest is a big step.",
        headingSubstring: "Thank you for taking the test.",
        headingFont: heading,
        bodyFont: body
    )
    return TakingIntroLastThankYouHeaderView(attributedText: attr)
        .padding()
        .background(Color("AppBackGroundColor"))
}
#endif
