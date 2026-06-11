//
//  ModerationBodyTextView.swift
//  Calmscient
//
//  Closing copy with highlighted heavy-drinking limits.
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ModerationBodyTextView: View {

    let bodyText: AttributedString

    var body: some View {
        Text(bodyText)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Moderation body") {
    let bodyFont = LoginDesignSystem.Typography.lexendLight(size: 16)
    let content = ModerationPresentation.previewContent()
    return ModerationBodyTextView(bodyText: content.bodyAttributedText)
        .padding(.horizontal, 20)
}
#endif
