//
//  TakingIntroLastActionButton.swift
//  Calmscient
//
//  Outlined primary action used on the Taking Control intro last screen.
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TakingIntroLastActionButton: View {
    let title: String
    let action: () -> Void

    private let accent = Color(red: 99 / 255, green: 107 / 255, blue: 179 / 255)

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                .foregroundStyle(accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color(.separator), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.18), radius: 2, x: 0, y: 1)
        }
        .padding(.top, 15)
        .padding(.bottom, 15)
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Action button") {
    TakingIntroLastActionButton(title: "Drinking Coach", action: {})
        .padding()
        .background(Color("AppBackGroundColor"))
}
#endif
