//
//  ScreeningResultScoreCardView.swift
//  Calmscient
//
//  PHQ-style result card with title, info action, score panel, and progress.
//
//  Vivek
//  15 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ScreeningResultScoreCardView: View {

    let screeningName: String
    let score: Int
    let totalScore: Int
    let progress: Double
    let scoreMarkedTitle: String
    let totalScoreTitle: String
    let onInfoTap: () -> Void

    private let scorePurple = Color("AppThemeColor")
    private let trackGray = Color(red: 0.92, green: 0.92, blue: 0.94)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerRow
                .padding(.horizontal, 16)
                .padding(.top, 16)

            ScreeningResultScorePanelView(
                score: score,
                totalScore: totalScore,
                scoreMarkedTitle: scoreMarkedTitle,
                totalScoreTitle: totalScoreTitle
            )
            .padding(.horizontal, 55)
            .padding(.top, 24)

            resultProgressBar
                .padding(.horizontal, 23)
                .padding(.top, 23)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity)
        .background(cardSurface)
    }

    private var headerRow: some View {
        HStack(alignment: .center) {
            Text(screeningName)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 18))
                .foregroundStyle(Color.black)

            Spacer(minLength: 8)

            Button(action: onInfoTap) {
                Image("InfoIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
        }
    }

    private var resultProgressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(trackGray)
                    .frame(height: 24)

                Capsule()
                    .fill(scorePurple)
                    .frame(width: geometry.size.width * progress, height: 24)
            }
        }
        .frame(height: 24)
    }

    private var cardSurface: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(Color("AppViewContentColor"))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color("AppViewBorderColor"), lineWidth: 1)
            )
            .shadow(color: Color("AppViewShadowColor").opacity(0.4), radius: 4, x: 0, y: 1)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Score card") {
    ScreeningResultScoreCardView(
        screeningName: "PHQ-9",
        score: 14,
        totalScore: 30,
        progress: 14.0 / 30.0,
        scoreMarkedTitle: "Score\nmarked",
        totalScoreTitle: "Total score",
        onInfoTap: {}
    )
    .padding()
}
#endif
