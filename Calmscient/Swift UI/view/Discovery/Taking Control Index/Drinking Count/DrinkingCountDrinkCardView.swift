//
//  DrinkingCountDrinkCardView.swift
//  Calmscient
//
//  Single drink card with increment badge, image, description, and stepper.
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct DrinkingCountDrinkCardView: View {

    let row: DrinkCountRowPresentation
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    private let cardBorderColor = Color(hex: "#F2F2F2")
    private let quantityBadgeBackground = Color(red: 0.91, green: 0.905, blue: 0.953)

    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .top) {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.yellow)
                    Text(row.formattedIncrementCount)
                        .font(LoginDesignSystem.Typography.lexendLight(size: 12))
                        .foregroundStyle(Color.primary)
                }

                Spacer()

                if row.showsQuantityBadge {
                    Text(row.formattedQuantity)
                        .font(LoginDesignSystem.Typography.lexendMedium(size: 14))
                        .foregroundStyle(LoginDesignSystem.ColorName.primaryGradientTop)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(quantityBadgeBackground)
                        )
                }
            }

            drinkImage
                .frame(height: 64)

            Text(row.drinkName)
                .font(LoginDesignSystem.Typography.lexendLight(size: 12))
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .frame(minHeight: 48)

            DrinkingCountStepperView(
                onDecrement: onDecrement,
                onIncrement: onIncrement
            )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(cardBorderColor, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
        )
    }

    @ViewBuilder
    private var drinkImage: some View {
        if let imageURL = row.imageURL {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    placeholderDrinkImage
                default:
                    ProgressView()
                }
            }
        } else {
            placeholderDrinkImage
        }
    }

    private var placeholderDrinkImage: some View {
        Image(systemName: "wineglass.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(LoginDesignSystem.ColorName.primaryGradientTop.opacity(0.35))
            .padding(8)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Drink card — with quantity") {
    DrinkingCountDrinkCardView(
        row: DrinkCountRowPresentation.previewRows()[0],
        onIncrement: {},
        onDecrement: {}
    )
    .padding()
}

@available(iOS 16.0, *)
#Preview("Drink card — empty quantity") {
    DrinkingCountDrinkCardView(
        row: DrinkCountRowPresentation.previewRows()[1],
        onIncrement: {},
        onDecrement: {}
    )
    .padding()
}
#endif
