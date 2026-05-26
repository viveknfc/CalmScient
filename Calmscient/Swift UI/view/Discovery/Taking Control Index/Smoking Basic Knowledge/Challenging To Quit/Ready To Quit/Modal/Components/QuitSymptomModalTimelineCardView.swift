//
//  QuitSymptomModalTimelineCardView.swift
//  Calmscient
//
//  Timeline instruction card for ready-to-quit symptom modals.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct QuitSymptomModalTimelineCardView: View {

    @Environment(\.colorScheme) private var colorScheme

    let bodyText: String

    private let cardCornerRadius: CGFloat = 10

    private var shadowColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.4) : Color.black.opacity(0.2)
    }

    var body: some View {
        Text(bodyText)
            .font(LoginDesignSystem.Typography.lexendLight(size: 14))
            .foregroundStyle(Color.primary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                    .fill(Color(uiColor: .systemBackground))
            )
            .shadow(color: shadowColor, radius: 5, x: 0, y: 2)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Quit symptom timeline card") {
    QuitSymptomModalTimelineCardView(
        bodyText: "Put on a new patch each morning to get a steady level of nicotine."
    )
    .padding()
}
#endif
