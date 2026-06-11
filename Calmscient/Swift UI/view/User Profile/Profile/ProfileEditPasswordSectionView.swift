//
//  ProfileEditPasswordSectionView.swift
//  Calmscient
//
//  Date: May 14, 2026
//  Card-style "Change password" block with outlined update action (matches profile spec layout).
//
//  Vivek
//  14 May 2026
//
import SwiftUI

@available(iOS 16.0, *)
struct ProfileEditPasswordSectionView: View {
    @ObservedObject var viewModel: PatientProfileEditViewModel

    private let cardBorder = Color(red: 0.88, green: 0.88, blue: 0.9)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("profile_edit_password_change_password".localized)
                .font(LoginDesignSystem.Typography.lexendSemiBold(size: 16))
                .foregroundStyle(Color.black)
                .padding(.bottom, 16)

            TitledTextFieldView(
                title: "profile_edit_password_old_password".localized,
                placeholder: "profile_edit_password_old_password".localized,
                text: $viewModel.oldPassword,
                isSecure: true,
                isSecureVisible: $viewModel.oldPasswordVisible,
                keyboardType: .default,
                textContentType: .password
            )

            TitledTextFieldView(
                title: "profile_edit_password_new_password".localized,
                placeholder: "profile_edit_password_new_password".localized,
                text: $viewModel.newPassword,
                isSecure: true,
                isSecureVisible: $viewModel.newPasswordVisible,
                keyboardType: .default,
                textContentType: .newPassword
            )
            .padding(.top, 14)

            TitledTextFieldView(
                title: "profile_edit_password_confirm_password".localized,
                placeholder: "profile_edit_password_confirm_password".localized,
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
                Text("profile_edit_password_update_password".localized)
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
