//
//  BasicStandardDrinkCarouselCardView.swift
//  Calmscient
//
//  Inner carousel card with drink image and caption.
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct BasicStandardDrinkCarouselCardView: View {

    let item: StandardDrinkCarouselItemPresentation

    private let cardFillColor = Color(red: 0.965, green: 0.965, blue: 1.0)
    private let captionColor = Color(red: 0.259, green: 0.259, blue: 0.259)

    var body: some View {
        VStack(spacing: 8) {
            drinkImage
                .frame(height: 98)

            Text(item.drinkName)
                .font(LoginDesignSystem.Typography.lexendMedium(size: 12))
                .foregroundStyle(captionColor)
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .frame(minHeight: 62)
                .padding(.horizontal, 8)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(cardFillColor)
        )
    }

    @ViewBuilder
    private var drinkImage: some View {
        if let imageURL = item.imageURL {
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
            .padding(.horizontal, 24)
        } else {
            placeholderDrinkImage
        }
    }

    private var placeholderDrinkImage: some View {
        Image(systemName: "wineglass.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(LoginDesignSystem.ColorName.primaryGradientTop.opacity(0.35))
            .padding(.horizontal, 40)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Carousel card") {
    BasicStandardDrinkCarouselCardView(
        item: StandardDrinkCarouselItemPresentation.previewItems()[0]
    )
    .padding()
}
#endif
