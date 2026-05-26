//
//  TakingControlIntroHeaderView.swift
//  Calmscient
//
//  Intro copy for the Taking Control CAGE-AID questionnaire.
//
//  Vivek
//  19 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TakingControlIntroHeaderView: View {

    let introText: AttributedString

    var body: some View {
        Text(introText)
            .foregroundStyle(Color.primary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Intro header") {
    let viewModel = TakingControlIntroViewModel()
    return TakingControlIntroHeaderView(introText: viewModel.introAttributedText)
        .padding()
}
#endif
