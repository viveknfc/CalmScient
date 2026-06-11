//
//  ProfileEditFieldComponents.swift
//  Calmscient
//
//  Date: May 14, 2026
//  Reusable bordered fields for the profile edit screen (editable + read-only variants).
//
//  Vivek
//  14 May 2026
//
import SwiftUI

@available(iOS 16.0, *)
private enum ProfileEditFieldChrome {
    static let corner: CGFloat = 7
    static let readOnlyFill = Color(red: 0.96, green: 0.96, blue: 0.97)
    static let borderGradient = LoginDesignSystem.ColorName.loginGradient
}

@available(iOS 16.0, *)
struct ProfileEditEditableField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    /// When set, removes these characters on input (matches legacy profile name fields).
    var forbiddenCharacters: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                .foregroundStyle(LoginDesignSystem.ColorName.titleGray)

            TextField(placeholder, text: $text)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                .foregroundStyle(Color.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: ProfileEditFieldChrome.corner, style: .continuous)
                        .stroke(ProfileEditFieldChrome.borderGradient, lineWidth: 1)
                )
                .onChange(of: text) { newValue in
                    guard let forbidden = forbiddenCharacters, !forbidden.isEmpty else { return }
                    let filtered = newValue.filter { ch in !forbidden.contains(ch) }
                    if filtered != newValue {
                        text = filtered
                    }
                }
        }
    }
}

@available(iOS 16.0, *)
struct ProfileEditReadOnlyField: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                .foregroundStyle(LoginDesignSystem.ColorName.titleGray)

            Text(value)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(ProfileEditFieldChrome.readOnlyFill)
                .overlay(
                    RoundedRectangle(cornerRadius: ProfileEditFieldChrome.corner, style: .continuous)
                        .stroke(ProfileEditFieldChrome.borderGradient, lineWidth: 1)
                )
        }
    }
}

@available(iOS 16.0, *)
struct ProfileEditSubmitButton: View {
    let title: String
    var isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 17))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(LoginDesignSystem.ColorName.loginGradient)
                )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.55)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Profile fields") {
    VStack(spacing: 16) {
        ProfileEditEditableField(title: "First Name", placeholder: "First Name", text: .constant("A"), forbiddenCharacters: nil)
        ProfileEditReadOnlyField(title: "Email", value: "a@b.com")
        ProfileEditSubmitButton(title: "Submit", isEnabled: true, action: {})
    }
    .padding()
}
#endif
