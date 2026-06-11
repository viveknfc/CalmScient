//
//  DrinkCountRowPresentation.swift
//  Calmscient
//
//  Presentation model for a drink card on the drink counts calculator screen.
//
//  Vivek
//  21 May 2026
//

import Foundation

struct DrinkCountRowPresentation: Identifiable, Equatable {
    let id: Int
    let drinkName: String
    let imageURL: URL?
    let incrementCount: Double
    var quantity: Double

    var showsQuantityBadge: Bool {
        quantity > 0
    }

    var formattedIncrementCount: String {
        Self.formatCount(incrementCount)
    }

    var formattedQuantity: String {
        Self.formatCount(quantity)
    }

    static func formatCount(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        }
        return String(format: "%.1f", value)
    }
}

struct DrinkingCountDrinksListResponse: Decodable {
    let totalCount: FlexibleDouble?
    let date: String?
    let drinksList: [DrinkingCountDrinkItem]?

    enum CodingKeys: String, CodingKey {
        case totalCount
        case date
        case drinksList
    }
}

struct DrinkingCountDrinkItem: Decodable {
    let drinkId: Int?
    let drinkName: String?
    let imageUrl: String?
    let quantity: FlexibleDouble?
    let incrementCount: FlexibleDouble?
}

/// Decodes numeric JSON values that may arrive as `Int`, `Double`, or `String`.
struct FlexibleDouble: Decodable {
    let value: Double

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let intValue = try? container.decode(Int.self) {
            value = Double(intValue)
        } else if let stringValue = try? container.decode(String.self) {
            value = Double(stringValue) ?? 0
        } else {
            value = 0
        }
    }
}

#if DEBUG
extension DrinkCountRowPresentation {
    static func previewRows() -> [DrinkCountRowPresentation] {
        [
            DrinkCountRowPresentation(
                id: 1,
                drinkName: "Regular beer (12 fl oz) about 5% alcohol",
                imageURL: nil,
                incrementCount: 1.0,
                quantity: 4.0
            ),
            DrinkCountRowPresentation(
                id: 2,
                drinkName: "Glass of table wine (5 fl oz) about 12% alcohol",
                imageURL: nil,
                incrementCount: 1.0,
                quantity: 0
            ),
            DrinkCountRowPresentation(
                id: 3,
                drinkName: "Margarita (3 fl oz) about 15% alcohol",
                imageURL: nil,
                incrementCount: 1.7,
                quantity: 0
            ),
            DrinkCountRowPresentation(
                id: 4,
                drinkName: "Martini (2.2 fl oz) about 37% alcohol",
                imageURL: nil,
                incrementCount: 1.4,
                quantity: 0
            ),
        ]
    }
}
#endif
