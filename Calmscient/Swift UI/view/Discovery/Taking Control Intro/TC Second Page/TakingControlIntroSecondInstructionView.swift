//
//  TakingControlIntroSecondInstructionView.swift
//  Calmscient
//
//  Instruction copy for the follow-up screening chooser.
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TakingControlIntroSecondInstructionView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(LoginDesignSystem.Typography.lexendLight(size: 14))
            .foregroundStyle(.primary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Instruction") {
    TakingControlIntroSecondInstructionView(
        text: TakingControlIntroSecondLocalization.introInstruction.localized
    )
    .padding()
    .background(Color("AppBackGroundColor"))
}
#endif
