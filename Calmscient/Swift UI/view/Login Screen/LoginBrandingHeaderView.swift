//
//  LoginBrandingHeaderView.swift
//  Calmscient
//

import SwiftUI

struct LoginBrandingHeaderView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image("mainLogoNw")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 100)
        }
    }
}

#if DEBUG
#Preview("Login branding") {
    LoginBrandingHeaderView()
        .padding()
}
#endif
