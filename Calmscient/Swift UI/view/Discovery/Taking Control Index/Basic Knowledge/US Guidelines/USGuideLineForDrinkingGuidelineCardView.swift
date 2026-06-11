//
//  USGuideLineForDrinkingGuidelineCardView.swift
//  Calmscient
//
//  Men/Women guideline card (parity with storyboard `RoundedView1` rows).
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct USGuideLineForDrinkingGuidelineCardView: View {

    let card: USDrinkingGuidelineCardPresentation

    private let detailPurple = Color(red: 0.427, green: 0.419, blue: 0.682)
    private let cardBorder = Color("AppBorderColor")

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(card.genderLabel)
                .font(LoginDesignSystem.Typography.lexendMedium(size: 16))
                .foregroundStyle(Color.primary)
                .frame(minWidth: 56, alignment: .leading)

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 2) {
                ForEach(Array(card.detailLines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.enumerated()), id: \.offset) { _, line in
                    Text(line)
                        .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                        .foregroundStyle(detailPurple)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .frame(minHeight: 70)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(cardBorder.opacity(0.35), lineWidth: 1)
        )
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Guideline card — single line") {
    USGuideLineForDrinkingGuidelineCardView(
        card: USDrinkingGuidelineCardPresentation(
            id: "preview-men",
            genderLabel: "Men",
            detailLines: ["Up to 2 drinks per day"]
        )
    )
    .padding(.horizontal, 20)
}

@available(iOS 16.0, *)
#Preview("Guideline card — two lines") {
    USGuideLineForDrinkingGuidelineCardView(
        card: USDrinkingGuidelineCardPresentation(
            id: "preview-women",
            genderLabel: "Women",
            detailLines: [
                "Up to 4 or more drinks on",
                "any day or 8 drinks or more per week",
            ]
        )
    )
    .padding(.horizontal, 20)
}
#endif
