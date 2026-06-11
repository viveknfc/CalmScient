//
//  ScreeningResultMoreInfoOverlayView.swift
//  Calmscient
//
//  More Info modal overlay (parity with legacy `CustomAlertMoreInfoView`).
//
//  Vivek
//  15 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ScreeningResultMoreInfoOverlayView: View {

    let onDismiss: () -> Void

    private var descriptionText: String {
        "This assessment is based on the Patient Health Questionnaire (PHQ), which is a self-administered version of the PRIME-MD diagnostic instrument for common mental disorders.\n\nPHQ9 Copyright © Pfizer Inc. All rights reserved. Reproduced with permission. PRIME-MD ® is a trademark of Pfizer Inc.".localized
    }

    private var linksText: String {
        "US National Institute of HealthAmerican Psychological AssociationStamford University".localized
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture(perform: onDismiss)

            VStack(spacing: 12) {
                Text("More Info".localized)
                    .font(LoginDesignSystem.Typography.lexendSemiBold(size: 16))
                    .foregroundStyle(Color("424242Color"))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 15)

                Text(descriptionText)
                    .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                    .foregroundStyle(Color.primary.opacity(0.85))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(linksText)
                    .font(LoginDesignSystem.Typography.lexendMedium(size: 14))
                    .foregroundStyle(Color("AppBorderColor"))
                    .underline()
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
                    .frame(maxWidth: .infinity)

                Button(action: onDismiss) {
                    Text("Ok".localized)
                        .font(LoginDesignSystem.Typography.lexendSemiBold(size: 17))
                        .foregroundStyle(Color.white)
                        .frame(width: 150, height: 40)
                        .background(
                            Capsule(style: .continuous)
                                .fill(LoginDesignSystem.ColorName.loginGradient)
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 12)
                .padding(.bottom, 12)
            }
            .padding(.horizontal, 16)
            .background(Color("AppBackGroundColor"))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(.horizontal, 20)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("More info overlay") {
    ScreeningResultMoreInfoOverlayView(onDismiss: {})
}
#endif
