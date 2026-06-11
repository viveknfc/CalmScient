//
//  HomeDashboardHeaderView.swift
//  Calmscient
//
//  Vivek
//  14 May 2026
//
import SwiftUI

@available(iOS 16.0, *)
struct HomeDashboardHeaderView: View {

    let firstName: String
    let onProfileTap: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("Hello".localized)
                        .font(LoginDesignSystem.Typography.lexendLight(size: 32))
                    Text(firstName)
                        .font(LoginDesignSystem.Typography.lexendSemiBold(size: 32))
                }
                .foregroundStyle(LoginDesignSystem.ColorName.titleGray)

                Text("We are happy to see you".localized)
                    .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                    .foregroundStyle(LoginDesignSystem.ColorName.footerGray)
            }

            Spacer(minLength: 8)

            Button(action: onProfileTap) {
                Image("profileIcon")
                    .font(.system(size: 36))
            }
            .buttonStyle(.plain)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Home header") {
    HomeDashboardHeaderView(firstName: "Samantha", onProfileTap: {})
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(LoginDesignSystem.ColorName.pageBackground)
}
#endif

