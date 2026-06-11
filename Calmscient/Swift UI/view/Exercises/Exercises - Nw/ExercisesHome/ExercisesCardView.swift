//
//  ExercisesCardView.swift
//  Calmscient
//
//  Single exercise tile in the Exercises grid.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ExercisesCardView: View {

    let title: String
    let imageName: String
    let onTap: () -> Void

    private let cardHeight: CGFloat = 125
    private let cornerRadius: CGFloat = 10

    var body: some View {
        Button(action: onTap) {
            cardContent
        }
        .buttonStyle(.plain)
    }

    private var cardContent: some View {
        ZStack(alignment: .bottomLeading) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.55),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            Text(title)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                .foregroundStyle(Color.white)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .padding(10)
        }
        .frame(height: cardHeight)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .compositingGroup()
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 0)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Exercise card") {
    ExercisesCardView(
        title: "Mindfulness - what is it?",
        imageName: "mindfulness",
        onTap: {}
    )
    .padding(16)
    .frame(width: 180)
}
#endif
