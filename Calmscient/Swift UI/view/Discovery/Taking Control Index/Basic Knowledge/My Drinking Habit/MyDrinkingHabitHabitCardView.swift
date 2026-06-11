//
//  MyDrinkingHabitHabitCardView.swift
//  Calmscient
//
//  Selectable drinking habit card (parity with `VivCustomTableViewCell`).
//
//  Vivek
//  25 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MyDrinkingHabitHabitCardView: View {

    let card: DrinkingHabitCardPresentation
    let onTap: () -> Void

    private let titleFont = LoginDesignSystem.Typography.lexendRegular(size: 14)
    private let bulletFont = LoginDesignSystem.Typography.lexendLight(size: 14)

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 15) {
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

                ForEach(Array(card.localizedBullets.enumerated()), id: \.offset) { _, bullet in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(Color.primary)
                            .padding(.top, 6)

                        Text(bullet)
                            .font(bulletFont)
                            .foregroundStyle(Color.primary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
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
#Preview("Habit card — selected") {
    MyDrinkingHabitHabitCardView(
        card: DrinkingHabitCardPresentation(
            id: 0,
            titleKey: "Moderate drinking",
            bulletKeys: ["Always drink with the moderate drinking standard."],
            isSelected: true
        ),
        onTap: {}
    )
    .padding(.horizontal, 20)
}

@available(iOS 16.0, *)
#Preview("Habit card — unselected") {
    MyDrinkingHabitHabitCardView(
        card: DrinkingHabitCardPresentation(
            id: 1,
            titleKey: "Moderate everyday drinking",
            bulletKeys: ["Drink daily as sleep aids or relaxation."],
            isSelected: false
        ),
        onTap: {}
    )
    .padding(.horizontal, 20)
}
#endif
