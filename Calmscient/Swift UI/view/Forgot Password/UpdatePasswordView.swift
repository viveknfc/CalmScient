//
//  UpdatePasswordView.swift
//  Calmscient
//
//  Vivek
//  14 May 2026
//
import SwiftUI

@available(iOS 16.0, *)
struct UpdatePasswordView: View {
    @ObservedObject var viewModel: UpdatePasswordViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            LoginDesignSystem.ColorName.pageBackground
                .ignoresSafeArea()

            Image("waveBackground")
                .frame(height: 180)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea(edges: .bottom)

            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        LoginBrandingHeaderView()
                            .padding(.top, 36)
                            .padding(.bottom, 36)

                        VStack(alignment: .leading, spacing: 0) {
                            Text(AppHelper.getLocalizeString(str: "Set a new password"))
                                .font(LoginDesignSystem.Typography.lexendMedium(size: 20))
                                .foregroundStyle(LoginDesignSystem.ColorName.navy)
                                .padding(.top, 24)

                            Text(AppHelper.getLocalizeString(str: "Create a new password. Ensure it differs from previous ones for security"))
                                .font(LoginDesignSystem.Typography.lexendLight(size: 16))
                                .foregroundStyle(LoginDesignSystem.ColorName.titleGray)
                                .padding(.top, 16)

                            TitledTextFieldView(
                                title: AppHelper.getLocalizeString(str: "Password"),
                                placeholder: AppHelper.getLocalizeString(str: "Password"),
                                text: $viewModel.newPassword,
                                isSecure: true,
                                isSecureVisible: $viewModel.newPasswordVisible,
                                keyboardType: .default,
                                textContentType: .newPassword
                            )
                            .padding(.top, 22)

                            TitledTextFieldView(
                                title: AppHelper.getLocalizeString(str: "Confirm Password"),
                                placeholder: AppHelper.getLocalizeString(str: "Confirm Password"),
                                text: $viewModel.confirmPassword,
                                isSecure: true,
                                isSecureVisible: $viewModel.confirmPasswordVisible,
                                keyboardType: .default,
                                textContentType: .newPassword
                            )
                            .padding(.top, 16)

                            LoginGradientButton(
                                title: AppHelper.getLocalizeString(str: "Update Password"),
                                isEnabled: !viewModel.isSubmitting,
                                action: { viewModel.submit() }
                            )
                            .padding(.top, 28)
                            .padding(.bottom, 40)
                        }
                        .padding(.horizontal, 28)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(minHeight: geometry.size.height)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Update password") {
    UpdatePasswordView(viewModel: UpdatePasswordViewModel(email: "user@example.com"))
}
#endif
