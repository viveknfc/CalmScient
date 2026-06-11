//
//  ConSub2NumberedListView.swift
//  Calmscient
//
//  Numbered list for Alcohol-related mental dysfunction (parity with `ConSub2VC` storyboard).
//
//  Vivek
//  25 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ConSub2NumberedListView: View {

    let items: [String]

    private let bodyFont = LoginDesignSystem.Typography.lexendLight(size: 14)
    private let bodyColor = Color("424242Color")
    private let rowSpacing: CGFloat = 12
    private let numberColumnWidth: CGFloat = 15

    var body: some View {
        VStack(alignment: .leading, spacing: rowSpacing) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 5) {
                    Text("\(index + 1).")
                        .font(bodyFont)
                        .foregroundStyle(bodyColor)
                        .frame(width: numberColumnWidth, alignment: .leading)

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
#Preview("ConSub2 numbered list") {
    ConSub2NumberedListView(items: ConSub2Presentation.previewContent().numberedItems)
        .padding(.horizontal, 20)
}
#endif
