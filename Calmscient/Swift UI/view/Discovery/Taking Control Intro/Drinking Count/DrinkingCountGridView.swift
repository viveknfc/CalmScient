//
//  DrinkingCountGridView.swift
//  Calmscient
//
//  Two-column grid of drink quantity cards.
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct DrinkingCountGridView: View {

    let rows: [DrinkCountRowPresentation]
    let onIncrement: (Int) -> Void
    let onDecrement: (Int) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(rows) { row in
                DrinkingCountDrinkCardView(
                    row: row,
                    onIncrement: { onIncrement(row.id) },
                    onDecrement: { onDecrement(row.id) }
                )
            }
        }
        .padding(.horizontal, 20)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Drinking count grid") {
    ScrollView {
        DrinkingCountGridView(
            rows: DrinkCountRowPresentation.previewRows(),
            onIncrement: { _ in },
            onDecrement: { _ in }
        )
    }
}
#endif
