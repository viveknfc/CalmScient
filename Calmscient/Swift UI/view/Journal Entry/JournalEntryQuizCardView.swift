//
//  JournalEntryQuizCardView.swift
//  Calmscient
//
//  Questionnaire completion card (title band, date, progress, score).
//
//  Vivek
//  18 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct JournalEntryQuizCardView: View {

    let row: JournalQuizRowPresentation

    private let scorePurple = Color(red: 0.431, green: 0.420, blue: 0.702)
    private let dateGray = Color(red: 0.608, green: 0.608, blue: 0.608)
    private let trackGray = Color(red: 0.92, green: 0.92, blue: 0.94)
    private let sectionGray = Color(red: 0.55, green: 0.55, blue: 0.55)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(row.sectionTitle)
                .font(LoginDesignSystem.Typography.lexendMedium(size: 12))
                .foregroundStyle(sectionGray)
                .textCase(.uppercase)

            Text(row.dateTimeText)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                .foregroundStyle(dateGray)

            quizProgressBar(progress: row.progress)

            scoreLabel
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardSurface)
    }

    private func quizProgressBar(progress: Double) -> some View {
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
            Text("\(row.score)")
                .font(LoginDesignSystem.Typography.lexendRegular(size: 15))
                .foregroundStyle(scorePurple)

            Text(" / ")
                .font(LoginDesignSystem.Typography.lexendRegular(size: 15))
                .foregroundStyle(dateGray)

            Text("\(row.totalScore)")
                .font(LoginDesignSystem.Typography.lexendRegular(size: 15))
                .foregroundStyle(Color.black)
        }
    }

    private var cardSurface: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color(UIColor.systemGray5), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 3, x: 0, y: 2)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Quiz card") {
    JournalEntryQuizCardView(
        row: JournalQuizRowPresentation(
            id: "1",
            sectionTitle: "PHQ-9",
            dateTimeText: "05/15/2026 | 07:22 PM",
            score: 17,
            totalScore: 30
        )
    )
    .padding()
}
#endif
