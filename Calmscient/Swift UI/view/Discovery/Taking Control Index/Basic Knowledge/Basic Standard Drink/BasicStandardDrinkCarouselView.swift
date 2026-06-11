//
//  BasicStandardDrinkCarouselView.swift
//  Calmscient
//
//  Drink carousel with previous and next controls (parity with `BasicStandardDrink` storyboard).
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct BasicStandardDrinkCarouselView: View {

    let item: StandardDrinkCarouselItemPresentation?
    let canShowPrevious: Bool
    let canShowNext: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void

    private let outerBorderColor = Color(hex: "#F6F6FF")

    var body: some View {
        ZStack {
            if let item {
                BasicStandardDrinkCarouselCardView(item: item)
                    .padding(8)
            } else {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(red: 0.965, green: 0.965, blue: 1.0))
                    .frame(height: 204)
                    .padding(8)
            }

            HStack {
                carouselNavButton(imageName: "reward", isEnabled: canShowPrevious, action: onPrevious)
                Spacer()
                carouselNavButton(imageName: "forward", isEnabled: canShowNext, action: onNext)
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 222)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(outerBorderColor, lineWidth: 1)
                )
        )
    }

    private func carouselNavButton(
        imageName: String,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.4)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Standard drink carousel") {
    BasicStandardDrinkCarouselView(
        item: StandardDrinkCarouselItemPresentation.previewItems()[0],
        canShowPrevious: false,
        canShowNext: true,
        onPrevious: {},
        onNext: {}
    )
    .padding(.horizontal, 20)
}
#endif
