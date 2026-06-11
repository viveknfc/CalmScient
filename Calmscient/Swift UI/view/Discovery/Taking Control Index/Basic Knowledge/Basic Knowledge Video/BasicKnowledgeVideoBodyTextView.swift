//
//  BasicKnowledgeVideoBodyTextView.swift
//  Calmscient
//
//  Explanatory copy below the brain video player.
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct BasicKnowledgeVideoBodyTextView: View {

    let text: String

    private let textColor = Color("424242Color")

    var body: some View {
        Text(text)
            .font(LoginDesignSystem.Typography.lexendLight(size: 14))
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Brain video body text") {
    BasicKnowledgeVideoBodyTextView(
        text: "This video explains the impact of alcohol on the brain and its subsequent effects. Having this knowledge will help you consider your drinking habits.".localized
    )
    .padding(.horizontal, 16)
}
#endif
