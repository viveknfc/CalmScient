//
//  DayFeedbackTimeSpendCard.swift
//  Calmscient
//
//  One card: “who did you spend time with?” + selection row.
//
//  Vivek
//  14 May 2026
//
import SwiftUI
import UIKit

@available(iOS 16.0, *)
struct DayFeedbackTimeSpendCard: View {
    @ObservedObject var viewModel: UserIntroDayFeedbackViewModel

    var body: some View {
        DayFeedbackFeedbackCard {
            VStack(alignment: .leading, spacing: 12) {
                DayFeedbackRequiredQuestionTitle(plainText: Self.timeSpendQuestion(from: viewModel))
                DayFeedbackTimeSpendOptionsRow(viewModel: viewModel)
            }
        }
    }

    private static func timeSpendQuestion(from viewModel: UserIntroDayFeedbackViewModel) -> String {
        let fallback = AppHelper.getLocalizeString(str: "UserIntro_fallback_time_spend")
        guard let ts = viewModel.templateData?.timeSpendData else { return fallback }
        let q = ts.timeSpendQuestion.trimmingCharacters(in: .whitespacesAndNewlines)
        return q.isEmpty ? fallback : ts.timeSpendQuestion
    }
}

@available(iOS 16.0, *)
private struct DayFeedbackTimeSpendOptionsRow: View {
    @ObservedObject var viewModel: UserIntroDayFeedbackViewModel
    private let pairs = DayFeedbackLayout.timeSpendPairs

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            ForEach(pairs.indices, id: \.self) { idx in
                let pair = pairs[idx]
                let isOn = viewModel.spendSelectedIndices.contains(idx)
                Button {
                    viewModel.toggleSpendIndex(idx)
                } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            Image(uiImage: UIImage(named: isOn ? DayFeedbackLayout.selectedFamilyImages[idx] : pair.0) ?? UIImage())
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
                            .foregroundStyle(isOn ? Color("barColor1") : Color("UserIntroCollectionCellBackgroundColor"))
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

#if DEBUG
@available(iOS 16.0, *)
#Preview("Time Spend Card") {
    let vm = UserIntroDayFeedbackViewModel()
    vm.spendSelectedIndices = [0, 2]
    return DayFeedbackTimeSpendCard(viewModel: vm)
        .padding()
        .background(Color(red: 0.96, green: 0.96, blue: 0.97))
}
#endif
