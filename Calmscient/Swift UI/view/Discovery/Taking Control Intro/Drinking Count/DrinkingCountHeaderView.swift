//
//  DrinkingCountHeaderView.swift
//  Calmscient
//
//  Subtitle and total count summary for the drink counts calculator.
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct DrinkingCountHeaderView: View {

    let subtitle: String
    let totalLabelLineOne: String
    let totalLabelLineTwo: String
    let totalValue: String

    private let totalBoxBackground = Color(red: 0.91, green: 0.905, blue: 0.953)

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(subtitle)
                .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                .foregroundStyle(Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 5) {
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(totalLabelLineOne)
                            .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                        Text(totalLabelLineTwo)
                            .font(LoginDesignSystem.Typography.lexendLight(size: 12))
                            .foregroundStyle(Color(red: 0.33, green: 0.33, blue: 0.33))
                    }

                    Text(totalValue)
                        .font(LoginDesignSystem.Typography.lexendMedium(size: 16))
                        .foregroundStyle(Color.primary)
                        .frame(minWidth: 70, minHeight: 35)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(totalBoxBackground)
                        )
                }
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Drinking count header") {
    DrinkingCountHeaderView(
        subtitle: "Now let's see what drinking habits do you have",
        totalLabelLineOne: "Total",
        totalLabelLineTwo: "count",
        totalValue: "9.4"
    )
}
#endif
