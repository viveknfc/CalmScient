//
//  LoginView.swift
//  Calmscient
//
//  Vivek
//  14 May 2026
//
import SwiftUI

@available(iOS 16.0, *)
struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel

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
                VStack(spacing: 0) {
                    LoginBrandingHeaderView()
                        .padding(.top, 36)
                        .padding(.bottom, 36)
                    
                    VStack(alignment: .leading, spacing: 18) {
                        TitledTextFieldView(
                            title: AppHelper.getLocalizeString(str: "Username"),
                            placeholder: AppHelper.getLocalizeString(str: "Username"),
                            text: $viewModel.username,
                            isSecure: false,
                            isSecureVisible: .constant(false),
                            keyboardType: .emailAddress,
                            textContentType: .username
                        )
                        
                        TitledTextFieldView(
                            title: AppHelper.getLocalizeString(str: "Password"),
                            placeholder: AppHelper.getLocalizeString(str: "Password"),
                            text: $viewModel.password,
                            isSecure: true,
                            isSecureVisible: $viewModel.isPasswordVisible,
                            textContentType: .password
                        )
                    }
                    .padding(.horizontal, 28)
                    
                    LoginCheckboxesSection(
                        acceptTermsSelected: $viewModel.acceptTermsSelected,
                        rememberMeSelected: $viewModel.rememberMeSelected,
                        onTermsLink: { viewModel.openTermsOfService() }
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 28)
                    .padding(.top, 22)
                    
                    LoginGradientButton(
                        title: NSLocalizedString("Login", comment: ""),
                        isEnabled: !viewModel.isPerformingLogin,
                        action: { viewModel.submitLogin() }
                    )
                    .padding(.horizontal, 28)
                    .padding(.top, 28)
                    
                    LoginFooterLinksView(
                        onForgotPassword: { viewModel.navigateForgotPassword() },
                        onValidateLicense: { viewModel.navigateLicenseValidation() }
                    )
                    .padding(.horizontal, 28)
                    .padding(.top, 20)
                    .padding(.bottom, 48)
                }
                .padding()
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
#Preview("Login") {
    LoginView(viewModel: LoginViewModel())
}
#endif
