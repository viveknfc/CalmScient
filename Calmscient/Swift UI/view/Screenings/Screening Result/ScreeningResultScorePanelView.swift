//
//  ScreeningResultScorePanelView.swift
//  Calmscient
//
//  Diagonal split score panel (parity with legacy storyboard score section).
//
//  Vivek
//  15 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ScreeningResultScorePanelView: View {

    let score: Int
    let totalScore: Int
    let scoreMarkedTitle: String
    let totalScoreTitle: String

    private let scorePurple = Color("6E6BB3ColorOnly")
    private let totalGray = Color(white: 0.67)

    var body: some View {
        HStack(spacing: 0) {
            markedScoreSection
            totalScoreSection
        }
        .frame(height: 60)
        .background(Color("AppViewTextColor"))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var markedScoreSection: some View {
        ZStack(alignment: .leading) {
            Image("ScreeningResultBackground")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack(alignment: .center, spacing: 4) {
                Text(scoreMarkedTitle)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 10))
                    .foregroundStyle(scorePurple)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 74, alignment: .trailing)

                Text("\(score)")
                    .font(LoginDesignSystem.Typography.lexendMedium(size: 30))
                    .foregroundStyle(scorePurple)
                    .minimumScaleFactor(0.8)
            }
            .padding(.leading, 3)
            .padding(.trailing, 28)
        }
        .frame(maxWidth: .infinity)
    }

    private var totalScoreSection: some View {
        HStack(alignment: .center, spacing: 4) {
            Text("\(totalScore)")
                .font(LoginDesignSystem.Typography.lexendMedium(size: 30))
                .foregroundStyle(totalGray)

            Text(totalScoreTitle)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 10))
                .foregroundStyle(Color("One424242Color"))
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.trailing, 4)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Score panel") {
    ScreeningResultScorePanelView(
        score: 14,
        totalScore: 30,
        scoreMarkedTitle: "Score\nmarked",
        totalScoreTitle: "Total score"
    )
    .padding(.horizontal, 55)
}
#endif
