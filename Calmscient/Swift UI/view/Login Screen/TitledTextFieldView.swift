//
//  TitledTextFieldView.swift
//  Calmscient
//
//  Reusable titled field for login (username / password).
//
//  Vivek
//  14 May 2026
//
import SwiftUI
import UIKit

struct TitledTextFieldView: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    @Binding var isSecureVisible: Bool
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var autocapitalization: TextInputAutocapitalization = .never
    var disableAutocorrection: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                .foregroundStyle(LoginDesignSystem.ColorName.titleGray)

            HStack(spacing: 8) {
                Group {
                    if isSecure && !isSecureVisible {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                    }
                }
                .font(LoginDesignSystem.Typography.lexendLight(size: 16))
                .foregroundStyle(LoginDesignSystem.ColorName.navy)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled(disableAutocorrection)
                .textContentType(textContentType)

                if isSecure {
                    Button {
                        isSecureVisible.toggle()
                    } label: {
                        Image(systemName: isSecureVisible ? "eye" : "eye.slash")
                            .foregroundStyle(LoginDesignSystem.ColorName.placeholderGray)
                            .imageScale(.medium)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isSecureVisible ? "Hide password" : "Show password")
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(LoginDesignSystem.ColorName.pageBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(LoginDesignSystem.ColorName.loginGradient, lineWidth: 1)
            )
            .onChange(of: text) { newValue in
                let filtered = newValue.replacingOccurrences(of: " ", with: "")
                if filtered != newValue {
                    text = filtered
                }
            }
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("TitledTextField") {
    struct PreviewHolder: View {
        @State private var username = ""
        @State private var password = ""
        @State private var showPassword = false

        var body: some View {
            VStack(spacing: 20) {
                TitledTextFieldView(
                    title: "Username",
                    placeholder: "Username",
                    text: $username,
                    isSecure: false,
                    isSecureVisible: .constant(false),
                    keyboardType: .emailAddress,
                    textContentType: .username
                )
                TitledTextFieldView(
                    title: "Password",
                    placeholder: "Password",
                    text: $password,
                    isSecure: true,
                    isSecureVisible: $showPassword,
                    textContentType: .password
                )
            }
            .padding()
        }
    }
    return PreviewHolder()
}
#endif
