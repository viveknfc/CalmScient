//
//  ForgotPasswordView.swift
//  Calmscient
//
//  Vivek
//  14 May 2026
//
import SwiftUI

@available(iOS 16.0, *)
struct ForgotPasswordView: View {
    @ObservedObject var viewModel: ForgotPasswordViewModel

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
                        
                        Text(AppHelper.getLocalizeString(str: "Forgot password"))
                            .font(LoginDesignSystem.Typography.lexendMedium(size: 20))
                            .foregroundStyle(LoginDesignSystem.ColorName.navy)
                            .padding(.top, 24)
                        
                        Text(AppHelper.getLocalizeString(str: "Please enter your email to reset the password"))
                            .font(LoginDesignSystem.Typography.lexendLight(size: 16))
                            .foregroundStyle(LoginDesignSystem.ColorName.titleGray)
                            .padding(.top, 16)
                        
                        TitledTextFieldView(
                            title: AppHelper.getLocalizeString(str: "Your email/Phone number "),
                            placeholder: AppHelper.getLocalizeString(str: "Your email/Phone number "),
                            text: $viewModel.emailOrPhone,
                            isSecure: false,
                            isSecureVisible: .constant(false),
                            keyboardType: .emailAddress,
                            textContentType: .emailAddress
                        )
                        .padding(.top, 22)
                        
                        LoginGradientButton(
                            title: NSLocalizedString("Reset Password", comment: ""),
                            isEnabled: !viewModel.isSubmitting,
                            action: { viewModel.submitResetRequest() }
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
#Preview("Forgot password") {
    ForgotPasswordView(viewModel: ForgotPasswordViewModel())
}
#endif
