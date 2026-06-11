//
//  ConsequenceSeeSomeLineView.swift
//  Calmscient
//
//  Secondary intro line below the consequences body copy.
//
//  Vivek
//  25 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ConsequenceSeeSomeLineView: View {

    let text: String

    private let bodyFont = LoginDesignSystem.Typography.lexendLight(size: 15)
    private let bodyColor = Color("424242Color")

    var body: some View {
        Text(text)
            .font(bodyFont)
            .foregroundStyle(bodyColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Consequence see-some line") {
    ConsequenceSeeSomeLineView(text: "consequences_intro_see_some".localized)
        .padding(.horizontal, 20)
}
#endif
