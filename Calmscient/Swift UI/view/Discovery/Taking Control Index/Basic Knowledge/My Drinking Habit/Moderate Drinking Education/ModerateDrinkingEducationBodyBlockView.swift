//
//  ModerateDrinkingEducationBodyBlockView.swift
//  Calmscient
//
//  Plain or highlighted body copy for moderate-drinking education screens.
//
//  Vivek
//  25 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ModerateDrinkingEducationBodyBlockView: View {

    let block: ModerateDrinkingEducationBodyBlock

    private let textColor = Color("424242Color")

    var body: some View {
        switch block {
        case .plain(let text):
            Text(text)
                .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                .foregroundStyle(textColor)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        case .highlighted(let attributedText):
            ModerationBodyTextView(bodyText: attributedText)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Moderate drinking plain block") {
    ModerateDrinkingEducationBodyBlockView(
        block: .plain("moderate_drinking_body_1".localized)
    )
    .padding(.horizontal, 20)
}

@available(iOS 16.0, *)
#Preview("Moderate drinking highlighted block") {
    let content = ModerateDrinkingEducationPresentation.previewContent(variant: .moderateDrinking)
    let highlighted = content.bodyBlocks.compactMap { block -> AttributedString? in
        if case .highlighted(let text) = block { return text }
        return nil
    }.first ?? AttributedString()
    return ModerateDrinkingEducationBodyBlockView(block: .highlighted(highlighted))
        .padding(.horizontal, 20)
}
#endif
