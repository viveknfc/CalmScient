//
//  TakingControlResourceCardView.swift
//  Calmscient
//
//  Resource row with thumbnail, purple title, and description.
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TakingControlResourceCardView: View {

    let row: TakingControlResourceRowPresentation
    let onTap: () -> Void

    private let brandPurple = LoginDesignSystem.ColorName.primaryGradientTop
    private let cardBorder = Color(red: 0.90, green: 0.90, blue: 0.92)

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 14) {
                thumbnail
                VStack(alignment: .leading, spacing: 8) {
                    Text(row.title)
                        .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                        .foregroundStyle(brandPurple)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(row.description)
                        .font(LoginDesignSystem.Typography.lexendLight(size: 12))
                        .foregroundStyle(Color.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let ui = UIImage(named: row.imageName) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFill()
                .frame(width: 88, height: 88)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        } else {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(red: 0.92, green: 0.92, blue: 0.95))
                .frame(width: 88, height: 88)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Resource card") {
    TakingControlResourceCardView(
        row: TakingControlResourceRowPresentation(
            id: 0,
            title: "Breathing exercises",
            description: "Let's use breathing exercises to support your journey.",
            imageName: "BreathingTechnic"
        ),
        onTap: {}
    )
    .padding()
}
#endif
