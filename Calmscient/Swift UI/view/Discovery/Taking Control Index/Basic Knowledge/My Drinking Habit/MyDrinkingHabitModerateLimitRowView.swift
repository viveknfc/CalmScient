//
//  MyDrinkingHabitModerateLimitRowView.swift
//  Calmscient
//
//  Men / women moderate drinking limit row.
//
//  Vivek
//  25 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MyDrinkingHabitModerateLimitRowView: View {

    let label: String
    let value: String

    private let labelFont = LoginDesignSystem.Typography.lexendLight(size: 15)
    private let valueColor = Color("barColor1")

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Text(label)
                .font(labelFont)
                .foregroundStyle(Color.primary)

            Text(value)
                .font(labelFont)
                .foregroundStyle(valueColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Moderate limit row — men") {
    MyDrinkingHabitModerateLimitRowView(
        label: "Men:",
        value: "Up to 2 drinks/day"
    )
    .padding(.horizontal, 20)
}
#endif
