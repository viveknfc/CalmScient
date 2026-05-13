//
//  LicenseValidationView.swift
//  Calmscient
//

import SwiftUI

@available(iOS 16.0, *)
struct LicenseValidationView: View {
    @ObservedObject var viewModel: LicenseValidationViewModel

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
                        Text(AppHelper.getLocalizeString(str: "License Key"))
                            .font(LoginDesignSystem.Typography.lexendMedium(size: 20))
                            .foregroundStyle(LoginDesignSystem.ColorName.navy)
                            .padding(.top, 24)
                        
                        TitledTextFieldView(
                            title: AppHelper.getLocalizeString(str: "License Key"),
                            placeholder: AppHelper.getLocalizeString(str: "License Key"),
                            text: $viewModel.licenseKey,
                            isSecure: false,
                            isSecureVisible: .constant(false),
                            keyboardType: .default,
                            textContentType: nil
                        )
                        .padding(.top, 22)
                        
                        LoginGradientButton(
                            title: AppHelper.getLocalizeString(str: "Submit"),
                            isEnabled: !viewModel.isSubmitting,
                            action: { viewModel.submitLicense() }
                        )
                        .padding(.top, 28)
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 28)

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
#Preview("License validation") {
    LicenseValidationView(viewModel: LicenseValidationViewModel())
}
#endif
