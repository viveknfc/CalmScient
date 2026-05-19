//
//  HistoryCardView.swift
//  Calmscient
//
//  Single screening history entry with date, progress, and score.
//
//  Vivek
//  15 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct HistoryCardView: View {

    let dateTimeText: String
    let score: Int
    let totalScore: Int
    let progress: Double

    private let scorePurple = Color(red: 0.431, green: 0.420, blue: 0.702)
    private let dateGray = Color(red: 0.608, green: 0.608, blue: 0.608)
    private let slashGray = Color(red: 0.608, green: 0.608, blue: 0.608)
    private let trackGray = Color(red: 0.92, green: 0.92, blue: 0.94)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(dateTimeText)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                .foregroundStyle(dateGray)

            historyProgressBar

            scoreLabel
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardSurface)
    }

    private var historyProgressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(trackGray)
                    .frame(height: 8)

                Capsule()
                    .fill(scorePurple)
                    .frame(width: geometry.size.width * progress, height: 8)
            }
        }
        .frame(height: 8)
    }

    private var scoreLabel: some View {
        HStack(spacing: 0) {
            Text("\(score)")
                .font(LoginDesignSystem.Typography.lexendRegular(size: 15))
                .foregroundStyle(scorePurple)

            Text(" / ")
                .font(LoginDesignSystem.Typography.lexendRegular(size: 15))
                .foregroundStyle(slashGray)

            Text("\(totalScore)")
                .font(LoginDesignSystem.Typography.lexendRegular(size: 15))
                .foregroundStyle(Color.black)
        }
    }

    private var cardSurface: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color("AppViewBorderColor"), lineWidth: 1)
            )
            .shadow(color: Color("AppViewShadowColor").opacity(0.4), radius: 4, x: 0, y: 1)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("History card high score") {
    HistoryCardView(
        dateTimeText: "05/12/2026 | 12:35 PM",
        score: 25,
        totalScore: 30,
        progress: 25.0 / 30.0
    )
    .padding()
}

@available(iOS 16.0, *)
#Preview("History card mid score") {
    HistoryCardView(
        dateTimeText: "04/29/2026 | 1:28 PM",
        score: 17,
        totalScore: 30,
        progress: 17.0 / 30.0
    )
    .padding()
}
#endif
