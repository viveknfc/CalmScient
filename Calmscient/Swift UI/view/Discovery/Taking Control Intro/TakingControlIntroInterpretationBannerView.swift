//
//  TakingControlIntroInterpretationBannerView.swift
//  Calmscient
//
//  Interpretation banner below the CAGE-AID score.
//
//  Vivek
//  19 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TakingControlIntroInterpretationBannerView: View {

    let text: String

    private var bannerFill: Color {
        Color(red: 0.825, green: 0.873, blue: 0.945)
    }

    var body: some View {
        Text(text)
            .font(LoginDesignSystem.Typography.lexendLight(size: 14))
            .foregroundStyle(Color.primary)
            .multilineTextAlignment(.leading)
            .lineSpacing(6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(bannerFill)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Interpretation") {
    TakingControlIntroInterpretationBannerView(
        text: "Taking control CAGE interpretation".localized
    )
}
#endif
