//
//  BreathingTechniqueType1PreparationCardView.swift
//  Calmscient
//
//  Preparation card for the 4-7-8 breathing exercise detail screen.
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct BreathingTechniqueType1PreparationCardView: View {

    @Environment(\.colorScheme) private var colorScheme

    let header: String
    let bodyText: String

    private let textColor = Color("lineChartLabelColor")
    private let cardCornerRadius: CGFloat = 10

    private var shadowColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.4) : Color.black.opacity(0.2)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(header)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 15))
                .foregroundStyle(textColor)

            Text(bodyText)
                .font(LoginDesignSystem.Typography.lexendLight(size: 15))
                .foregroundStyle(textColor)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(cardBackground)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
            .fill(Color(uiColor: .systemBackground))
            .shadow(color: shadowColor, radius: 5, x: 0, y: 2)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Preparation card") {
    BreathingTechniqueType1PreparationCardView(
        header: "Preparation",
        bodyText: "First find a comfortable seated position. Ensure that you are at ease before beginning the rhythmic breathing pattern."
    )
    .padding()
}
#endif
