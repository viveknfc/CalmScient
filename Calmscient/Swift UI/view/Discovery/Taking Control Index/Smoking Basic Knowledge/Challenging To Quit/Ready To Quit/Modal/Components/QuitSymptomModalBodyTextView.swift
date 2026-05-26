//
//  QuitSymptomModalBodyTextView.swift
//  Calmscient
//
//  Body copy for ready-to-quit symptom modals.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct QuitSymptomModalBodyTextView: View {

    let text: String

    var body: some View {
        Text(text)
            .font(LoginDesignSystem.Typography.lexendLight(size: 15))
            .foregroundStyle(Color.primary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Quit symptom body text") {
    QuitSymptomModalBodyTextView(
        text: "When you're trying to quit smoking, pretty much everyone feels the urge to smoke from time to time."
    )
    .padding()
}
#endif
