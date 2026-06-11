//
//  ModerationBulletListView.swift
//  Calmscient
//
//  Bulleted reasons list for the moderation screen.
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ModerationBulletListView: View {

    let items: [String]

    private let bodyFont = LoginDesignSystem.Typography.lexendLight(size: 14)
    private let bodyColor = Color("424242Color")
    private let bullet = "\u{2022}"
    private let rowSpacing: CGFloat = 12

    var body: some View {
        VStack(alignment: .leading, spacing: rowSpacing) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: 8) {
                    Text(bullet)
                        .font(bodyFont)
                        .foregroundStyle(Color.black)
                        .padding(.leading, 4)

                    Text(item)
                        .font(bodyFont)
                        .foregroundStyle(bodyColor)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: false)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Moderation bullets") {
    ModerationBulletListView(
        items: [
            "moderation_primary_reason_1".localized,
            "moderation_primary_reason_2".localized,
            "moderation_primary_reason_3".localized,
        ]
    )
    .padding(.horizontal, 20)
}
#endif
