//
//  BreathingTechniqueExerciseCardView.swift
//  Calmscient
//
//  Tappable card for a single breathing exercise row.
//
//  Vivek
//  20 May 2026
//

import SwiftUI

struct BreathingTechniqueExerciseCardView: View {

    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let onTap: () -> Void

    private let titleColor = Color("blueAndWhite")
    private let cardCornerRadius: CGFloat = 10

    private var shadowColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.4) : Color.black.opacity(0.2)
    }

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(LoginDesignSystem.Typography.lexendLight(size: 15))
                .foregroundStyle(titleColor)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(color: shadowColor, radius: 5, x: 0, y: 2)
                )
                
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview("Breathing exercise card") {
    BreathingTechniqueExerciseCardView(
        title: "4-7-8 Breathing exercise",
        onTap: {}
    )
    .padding()
}
#endif
