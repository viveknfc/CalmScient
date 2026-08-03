//
//  DayFeedbackSleepCard.swift
//  Calmscient
//
//  Sleep hours question + selector + summary in one card.
//
//  Vivek
//  14 May 2026
//
import SwiftUI
import UIKit

@available(iOS 16.0, *)
struct DayFeedbackSleepCard: View {
    @ObservedObject var viewModel: UserIntroDayFeedbackViewModel

    var body: some View {
        DayFeedbackFeedbackCard {
            VStack(alignment: .leading, spacing: 12) {
                sleepHoursQuestionTitle()

                HStack(spacing: 8) {
                    ForEach(0 ..< 9, id: \.self) { idx in
                        let isOn = viewModel.sleepCollectionIndex == idx
                        Button {
                            viewModel.setSleepIndex(idx)
                        } label: {
                            Text(UserIntroDayFeedbackViewModel.sleepCircleLabel(at: idx))
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundStyle(
                                    Color(uiColor: isOn
                                            ? UIColor.white
                                            : (UIColor(named: "circleTextColor") ?? .darkGray))
                                )
                                .frame(width: 30, height: 30)
                                .background(
                                    Circle()
                                        .fill(Color(uiColor: isOn
                                                ? (UIColor(named: "circleCellSelectedColor") ?? .purple)
                                                : (UIColor(named: "circleFillColor") ?? .lightGray)))
                                )
                                .overlay(
                                    Circle()
                                        .stroke(
                                            Color(uiColor: isOn
                                                    ? (UIColor(named: "circleCellSelectedColor") ?? .purple)
                                                    : (UIColor(named: "circleIntroBorderColor") ?? .gray)),
                                            lineWidth: 1.5
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                HStack {
                    
                    Spacer()
                    
                    if !viewModel.sleepSummaryText.isEmpty {
                        Text(viewModel.sleepSummaryText)
                            .font(LoginDesignSystem.Typography.lexendLight(size: 13))
                            .foregroundStyle(LoginDesignSystem.ColorName.footerGray)
                    }
                }

            }
        }
    }

    private func sleepHoursQuestionTitle() -> some View {
        return Text("sleep_hours_question_last_night".localized)
            .font(LoginDesignSystem.Typography.lexendMedium(size: 16))
            .foregroundStyle(LoginDesignSystem.ColorName.titleGray)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Sleep Card") {
    let vm = UserIntroDayFeedbackViewModel()
    vm.sleepCollectionIndex = 3
    vm.sleepSummaryText = "6 Hours"
    return DayFeedbackSleepCard(viewModel: vm)
        .padding()
        .background(Color(red: 0.96, green: 0.96, blue: 0.97))
}
#endif
