//
//  BasicStandardDrinkIntroTextView.swift
//  Calmscient
//
//  Introductory copy with highlighted alcohol amounts.
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct BasicStandardDrinkIntroTextView: View {

    let introText: AttributedString

    var body: some View {
        Text(introText)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Standard drink intro") {
    let viewModel = BasicStandardDrinkViewModel()
    viewModel.reloadLocalizedStrings()
    return BasicStandardDrinkIntroTextView(introText: viewModel.introAttributedText)
        .padding(.horizontal, 20)
}
#endif
