//
//  LoginGradientButton.swift
//  Calmscient
//
//  Vivek
//  14 May 2026
//
import SwiftUI

struct LoginGradientButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(LoginDesignSystem.Typography.lexendSemiBold(size: 16))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule(style: .continuous)
                        .fill(LoginDesignSystem.ColorName.loginGradient)
                )
        }
        .padding(.horizontal, 20)
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.55)
    }
}

#if DEBUG
#Preview("Login button") {
    LoginGradientButton(title: "Login", isEnabled: true, action: {})
        .padding(.horizontal, 24)
}
#endif
