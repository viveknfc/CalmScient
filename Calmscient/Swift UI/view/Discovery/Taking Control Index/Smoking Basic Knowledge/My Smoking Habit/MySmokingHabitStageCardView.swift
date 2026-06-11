//
//  MySmokingHabitStageCardView.swift
//  Calmscient
//
//  Selectable smoking habit stage card (parity with `VivCustomTableViewCell` configureCell1).
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MySmokingHabitStageCardView: View {

    let card: SmokingHabitStageCardPresentation
    let onTap: () -> Void

    private let titleFont = LoginDesignSystem.Typography.lexendRegular(size: 14)
    private let bodyFont = LoginDesignSystem.Typography.lexendLight(size: 14)

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(card.localizedTitle)
                        .font(titleFont)
                        .foregroundStyle(Color.primary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if card.isSelected {
                        Image("check")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                    }
                }

                Text(card.localizedBody)
                    .font(bodyFont)
                    .foregroundStyle(Color.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Stage card — selected") {
    MySmokingHabitStageCardView(
        card: SmokingHabitStageCardPresentation(
            id: 0,
            titleKey: "smoking_habit_stage_thinking_title",
            bodyKey: "smoking_habit_stage_thinking_body",
            isSelected: true
        ),
        onTap: {}
    )
    .padding(.horizontal, 20)
}

@available(iOS 16.0, *)
#Preview("Stage card — unselected") {
    MySmokingHabitStageCardView(
        card: SmokingHabitStageCardPresentation(
            id: 1,
            titleKey: "smoking_habit_stage_ready_title",
            bodyKey: "smoking_habit_stage_ready_body",
            isSelected: false
        ),
        onTap: {}
    )
    .padding(.horizontal, 20)
}
#endif
