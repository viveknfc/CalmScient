//
// Vivek
// Date: May 14, 2026
//
//  ProfileEditPasswordSectionView.swift
//  Calmscient
//
//  Card-style "Change password" block with outlined update action (matches profile spec layout).
//

import SwiftUI

@available(iOS 16.0, *)
struct ProfileEditPasswordSectionView: View {
    @ObservedObject var viewModel: PatientProfileEditViewModel

    private let cardBorder = Color(red: 0.88, green: 0.88, blue: 0.9)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(NSLocalizedString("Change password", comment: ""))
                .font(LoginDesignSystem.Typography.lexendBold(size: 16))
                .foregroundStyle(Color.black)
                .padding(.bottom, 16)

            TitledTextFieldView(
                title: NSLocalizedString("Old password", comment: ""),
                placeholder: NSLocalizedString("Old password", comment: ""),
                text: $viewModel.oldPassword,
                isSecure: true,
                isSecureVisible: $viewModel.oldPasswordVisible,
                keyboardType: .default,
                textContentType: .password
            )

            TitledTextFieldView(
                title: NSLocalizedString("New password", comment: ""),
                placeholder: NSLocalizedString("New password", comment: ""),
                text: $viewModel.newPassword,
                isSecure: true,
                isSecureVisible: $viewModel.newPasswordVisible,
                keyboardType: .default,
                textContentType: .newPassword
            )
            .padding(.top, 14)

            TitledTextFieldView(
                title: NSLocalizedString("Confirm password", comment: ""),
                placeholder: NSLocalizedString("Confirm password", comment: ""),
                text: $viewModel.confirmPassword,
                isSecure: true,
                isSecureVisible: $viewModel.confirmPasswordVisible,
                keyboardType: .default,
                textContentType: .newPassword
            )
            .padding(.top, 14)

            Button {
                viewModel.updatePasswordTapped()
            } label: {
                Text(NSLocalizedString("Update password", comment: ""))
                    .font(LoginDesignSystem.Typography.lexendSemiBold(size: 16))
                    .foregroundStyle(Color(hex: "#6D6BB3"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .stroke(LoginDesignSystem.ColorName.loginGradient, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isUpdatingPassword)
            .opacity(viewModel.isUpdatingPassword ? 0.55 : 1)
            .padding(.top, 18)
            .padding(.horizontal, 25)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview {
    ProfileEditPasswordSectionView(viewModel: PatientProfileEditViewModel())
        .padding()
}
#endif
