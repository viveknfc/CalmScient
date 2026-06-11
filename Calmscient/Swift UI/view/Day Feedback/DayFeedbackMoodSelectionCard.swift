//
//  DayFeedbackMoodSelectionCard.swift
//  Calmscient
//
//  One card: mood question + emoji row (title visually part of the same cell as meds/journal).
//
//  Vivek
//  14 May 2026
//
import SwiftUI
import UIKit

@available(iOS 16.0, *)
struct DayFeedbackMoodSelectionCard: View {
    @ObservedObject var viewModel: UserIntroDayFeedbackViewModel

    var body: some View {
        DayFeedbackSelectionCard(
            title: Self.moodQuestion(from: viewModel),
            selectedIndex: viewModel.moodSelectedIndex,
            onSelect: { viewModel.setMoodIndex($0) }
        )
    }

    private static func moodQuestion(from viewModel: UserIntroDayFeedbackViewModel) -> String {
        guard let mood = viewModel.templateData?.moodData else {
            return UserDefaults.standard.bool(forKey: "Morning")
                ? AppHelper.getLocalizeString(str: "UserIntro_fallback_mood_morning")
                : AppHelper.getLocalizeString(str: "UserIntro_fallback_mood_today")
        }
        let trimmed = mood.moodQuestion.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { return mood.moodQuestion }
        return UserDefaults.standard.bool(forKey: "Morning")
            ? AppHelper.getLocalizeString(str: "UserIntro_fallback_mood_morning")
            : AppHelper.getLocalizeString(str: "UserIntro_fallback_mood_today")
    }
}

@available(iOS 16.0, *)
struct DayFeedbackFocusSelectionCard: View {
    @ObservedObject var viewModel: UserIntroDayFeedbackViewModel

    var body: some View {
        DayFeedbackSelectionCard(
            title: Self.focusQuestion(from: viewModel),
            selectedIndex: viewModel.focusSelectedIndex,
            onSelect: { viewModel.setFocusIndex($0) }
        )
    }

    private static func focusQuestion(from viewModel: UserIntroDayFeedbackViewModel) -> String {
        let fallback = AppHelper.getLocalizeString(str: "How is your focus/mental clarity")
        let question = viewModel.templateData?.focusData?.focusQuestion ?? fallback
        let trimmed = question.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : question
    }
}

@available(iOS 16.0, *)
private struct DayFeedbackSelectionCard: View {
    let title: String
    let selectedIndex: Int?
    let onSelect: (Int) -> Void

    private let pairs = DayFeedbackLayout.moodOptionPairs
    private let selectedColors: [Color] = [
        Color(hex: "#EF6D6D"),
        Color(hex: "#F28A91"),
        Color(hex: "#F8BEBD"),
        Color(hex: "#A19EBD"),
        Color(hex: "#6E6BB3")
    ]

    var body: some View {
        DayFeedbackFeedbackCard {
            VStack(alignment: .leading, spacing: 12) {
                DayFeedbackRequiredQuestionTitle(plainText: title)
                HStack(alignment: .top, spacing: 4) {
                    ForEach(pairs.indices, id: \.self) { idx in
                        let pair = pairs[idx]
                        let isOn = selectedIndex == idx
                        Button {
                            onSelect(idx)
                        } label: {
                            VStack(spacing: 4) {
                                ZStack {
                                    Image(uiImage: UIImage(named: pair.0) ?? UIImage())
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: isOn ? 52 : 46, height: isOn ? 52 : 46)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.gray.opacity(isOn ? 0.85 : 0), lineWidth: 3)
                                        )
                                        .shadow(color: .black.opacity(isOn ? 0.2 : 0), radius: isOn ? 6 : 0, x: 0, y: 3)
                                        .scaleEffect(isOn ? 1.05 : 1)
                                }
                                .frame(height: DayFeedbackSelectionLayout.iconSlotHeight)
                                .frame(maxWidth: .infinity)

                                Text(AppHelper.getLocalizeString(str: pair.1))
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundStyle(isOn ? selectedColors[idx] : Color("UserIntroCollectionCellBackgroundColor"))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.45)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: DayFeedbackSelectionLayout.captionLineHeight, alignment: .center)
                            }
                            .frame(maxWidth: .infinity, alignment: .top)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Mood Card") {
    let vm = UserIntroDayFeedbackViewModel()
    vm.moodSelectedIndex = 1
    return DayFeedbackMoodSelectionCard(viewModel: vm)
        .padding()
        .background(Color(red: 0.96, green: 0.96, blue: 0.97))
}

@available(iOS 16.0, *)
#Preview("Focus Card") {
    let vm = UserIntroDayFeedbackViewModel()
    vm.focusSelectedIndex = 3
    return DayFeedbackFocusSelectionCard(viewModel: vm)
        .padding()
        .background(Color(red: 0.96, green: 0.96, blue: 0.97))
}
#endif
