//
//  LoginFooterLinksView.swift
//  Calmscient
//

import SwiftUI

struct LoginFooterLinksView: View {
    var onForgotPassword: () -> Void
    var onValidateLicense: () -> Void

    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            Button(action: onForgotPassword) {
                if #available(iOS 16.0, *) {
                    Text(NSLocalizedString("Forgot Password", comment: ""))
                        .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                        .foregroundStyle(LoginDesignSystem.ColorName.footerGray)
                        .underline()
                } else {
                    // Fallback on earlier versions
                }
            }
            .buttonStyle(.plain)

            Button(action: onValidateLicense) {
                if #available(iOS 16.0, *) {
                    Text(NSLocalizedString("Validate your license key", comment: ""))
                        .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                        .foregroundStyle(LoginDesignSystem.ColorName.footerGray)
                        .underline()
                } else {
                    // Fallback on earlier versions
                }
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

#if DEBUG
#Preview("Footer links") {
    LoginFooterLinksView(onForgotPassword: {}, onValidateLicense: {})
        .padding()
}
#endif
