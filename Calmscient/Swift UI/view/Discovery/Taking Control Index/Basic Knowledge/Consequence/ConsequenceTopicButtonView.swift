//
//  ConsequenceTopicButtonView.swift
//  Calmscient
//
//  Outlined topic row for the consequences index (parity with `CurvedOutlineButton`).
//
//  Vivek
//  25 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ConsequenceTopicButtonView: View {

    let title: String
    let onTap: () -> Void

    private let titlePurple = Color(red: 0.427, green: 0.419, blue: 0.682)

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 16))
                .foregroundStyle(titlePurple)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(titlePurple, lineWidth: 1.5)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Consequence topic button") {
    ConsequenceTopicButtonView(title: "Fatalities and injuries".localized, onTap: {})
        .padding(.horizontal, 20)
}
#endif
