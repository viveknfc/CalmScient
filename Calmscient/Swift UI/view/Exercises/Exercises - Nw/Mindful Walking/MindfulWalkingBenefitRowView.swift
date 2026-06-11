//
//  MindfulWalkingBenefitRowView.swift
//  Calmscient
//
//  Single numbered benefit row, with title colored up to the colon.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MindfulWalkingBenefitRowView: View {

    let index: Int
    let text: String

    private let accentColor = Color(hex: "#6E6BB3")

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(index).")
                .font(LoginDesignSystem.Typography.lexendLight(size: 15))
                .foregroundStyle(Color.primary)

            benefitText
                .font(LoginDesignSystem.Typography.lexendLight(size: 15))
                .foregroundStyle(Color.primary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var benefitText: some View {
        if let colonIndex = text.firstIndex(of: ":") {
            let titlePart = String(text[..<colonIndex])
            let remainder = String(text[text.index(after: colonIndex)...])

            (
                Text(titlePart).foregroundColor(accentColor)
                + Text(":")
                + Text(remainder)
            )
        } else {
            Text(text)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Mindful walking benefit row") {
    MindfulWalkingBenefitRowView(
        index: 1,
        text: "Stress Reduction: Engaging in mindful walking can be an effective way to reduce stress and promote relaxation."
    )
    .padding()
}
#endif
