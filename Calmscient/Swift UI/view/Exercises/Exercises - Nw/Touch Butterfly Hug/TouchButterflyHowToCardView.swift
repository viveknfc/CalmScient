//
//  TouchButterflyHowToCardView.swift
//  Calmscient
//
//  How-to card (matches QuitSymptom timeline card styling).
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TouchButterflyHowToCardView: View {

    @Environment(\.colorScheme) private var colorScheme

    let text: String
    let imageName: String?

    private let cardCornerRadius: CGFloat = 10

    private var shadowColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.4) : Color.black.opacity(0.2)
    }

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text(text)
                .font(LoginDesignSystem.Typography.lexendLight(size: 15))
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 174, height: 150)
                    .accessibilityHidden(true)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
        )
        .shadow(color: shadowColor, radius: 5, x: 0, y: 2)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Touch butterfly how-to card") {
    TouchButterflyHowToCardView(
        text: "Interlock your thumbs to form a butterfly shape:",
        imageName: "butterfly 1"
    )
    .padding()
}
#endif

