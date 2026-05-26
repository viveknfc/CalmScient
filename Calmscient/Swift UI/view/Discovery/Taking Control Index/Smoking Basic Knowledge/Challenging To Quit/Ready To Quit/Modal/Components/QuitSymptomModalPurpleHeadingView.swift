//
//  QuitSymptomModalPurpleHeadingView.swift
//  Calmscient
//
//  Purple section heading for ready-to-quit symptom modals.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct QuitSymptomModalPurpleHeadingView: View {

    let text: String

    private let headingColor = Color(hex: "#6E6BB3")

    var body: some View {
        Text(text)
            .font(LoginDesignSystem.Typography.lexendMedium(size: 16))
            .foregroundStyle(headingColor)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Quit symptom purple heading") {
    QuitSymptomModalPurpleHeadingView(text: "Use quit-smoking medicines")
        .padding()
}
#endif
