//
//  TakingControlIntroScoreView.swift
//  Calmscient
//
//  “Your points” score display for the CAGE-AID intro.
//
//  Vivek
//  19 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TakingControlIntroScoreView: View {

    let title: String
    let score: Int

    private var scoreFill: Color {
        Color(red: 0.388, green: 0.420, blue: 0.702)
    }

    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                .foregroundStyle(Color(white: 0.33))
                .frame(maxWidth: .infinity)

            Text("\(score)")
                .font(LoginDesignSystem.Typography.lexendMedium(size: 20))
                .foregroundStyle(Color.white)
                .frame(width: 52, height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(scoreFill)
                )
        }
        .padding(.vertical, 8)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Score") {
    TakingControlIntroScoreView(title: "Your points", score: 2)
}
#endif
