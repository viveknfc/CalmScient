//
//  StandardDrinkCarouselItemPresentation.swift
//  Calmscient
//
//  Carousel row for the standard drink screen (parity with `BasicStandardDrink` API items).
//
//  Vivek
//  21 May 2026
//

import Foundation
import SwiftUI

struct StandardDrinkCarouselItemPresentation: Identifiable, Equatable {
    let id: Int
    let drinkName: String
    let imageURL: URL?

    static func carouselItems(from drinksList: [DrinkingCountDrinkItem]) -> [StandardDrinkCarouselItemPresentation] {
        drinksList
            .compactMap { item -> (Int, DrinkingCountDrinkItem)? in
                guard let drinkId = item.drinkId, drinkId >= 2 else { return nil }
                return (drinkId, item)
            }
            .sorted { $0.0 < $1.0 }
            .compactMap { drinkId, item in
                guard let name = item.drinkName, !name.isEmpty else { return nil }
                return StandardDrinkCarouselItemPresentation(
                    id: drinkId,
                    drinkName: name,
                    imageURL: item.imageUrl.flatMap { URL(string: $0) }
                )
            }
    }
}

enum BasicStandardDrinkPresentation {

    static let introHighlightKeys = [
        "standard drink highlight fluid ounces",
        "standard drink highlight grams",
    ]

    static func makeIntroAttributedText(
        fullText: String,
        bodyFont: Font
    ) -> AttributedString {
        var attributed = AttributedString(fullText)
        attributed.font = bodyFont
        attributed.foregroundColor = .primary

        let highlightColor = Color("barColor1")
        for key in introHighlightKeys {
            let phrase = key.localized
            guard !phrase.isEmpty, let range = attributed.range(of: phrase) else { continue }
            attributed[range].foregroundColor = highlightColor
        }
        return attributed
    }
}

#if DEBUG
extension StandardDrinkCarouselItemPresentation {
    static func previewItems() -> [StandardDrinkCarouselItemPresentation] {
        [
            StandardDrinkCarouselItemPresentation(
                id: 2,
                drinkName: "Regular beer (12 fl oz) about 5% alcohol",
                imageURL: nil
            ),
            StandardDrinkCarouselItemPresentation(
                id: 3,
                drinkName: "Glass of table wine (5 fl oz) about 12% alcohol",
                imageURL: nil
            ),
            StandardDrinkCarouselItemPresentation(
                id: 4,
                drinkName: "Malt liquor or flavored malt beverages such as hard seltzer (8-10 fl oz) about 7% alcohol",
                imageURL: nil
            ),
        ]
    }
}
#endif
