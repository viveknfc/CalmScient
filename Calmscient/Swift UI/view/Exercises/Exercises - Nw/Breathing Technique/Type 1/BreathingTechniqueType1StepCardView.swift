//
//  BreathingTechniqueType1StepCardView.swift
//  Calmscient
//
//  Instruction card for a single 4-7-8 breathing step.
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct BreathingTechniqueType1StepCardView: View {

    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let bodyText: String

    private let textColor = Color("lineChartLabelColor")
    private let cardCornerRadius: CGFloat = 10

    private var shadowColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.4) : Color.black.opacity(0.2)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 15))
                .foregroundStyle(textColor)

            Text(bodyText)
                .font(LoginDesignSystem.Typography.lexendLight(size: 15))
                .foregroundStyle(textColor)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: shadowColor, radius: 5, x: 0, y: 2)
        )
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Step card") {
    BreathingTechniqueType1StepCardView(
        title: "Step 1: Emptying the lungs",
        bodyText: "Begin by completely emptying your lungs of air. Allow yourself a moment to release any tension."
    )
    .padding()
}
#endif
