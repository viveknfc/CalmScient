//
//  TakingControlStatCardView.swift
//  Calmscient
//
//  Summary stat card used on Drinking and Smoking Taking Control tabs.
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TakingControlStatCardView: View {

    let card: TakingControlStatCardPresentation

    private let cardBackground = Color(red: 0.96, green: 0.96, blue: 0.97)
    private let subtitleGray = Color(red: 0.55, green: 0.55, blue: 0.58)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(card.title)
                .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                .foregroundStyle(Color.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.85)

            HStack(alignment: .center, spacing: 20) {
                iconView
                VStack(alignment: .leading, spacing: 2) {
                    if let subtitle = card.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(LoginDesignSystem.Typography.lexendLight(size: 12))
                            .foregroundStyle(subtitleGray)
                    }
                    Text(card.value)
                        .font(LoginDesignSystem.Typography.lexendMedium(size: 20))
                        .foregroundStyle(Color.primary)
                }
                Spacer(minLength: 0)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(cardBackground)
            )
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 108, alignment: .leading)

    }

    @ViewBuilder
    private var iconView: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.90, green: 0.90, blue: 0.92))
                .frame(width: 32, height: 32)
            if let asset = card.assetImageName, let ui = UIImage(named: asset) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            } else if let symbol = card.systemImageName {
                Image(systemName: symbol)
                    .font(.system(size: 20))
                    .foregroundStyle(Color.red.opacity(0.85))
            }
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Drinking stat card") {
    TakingControlStatCardView(card: TakingControlIndexPreviewData.drinkingStats()[0])
        .padding()
}
#endif
