//
//  TakingControlIntroSecondTestCardView.swift
//  Calmscient
//
//  Tappable white card for AUDIT or DAST-10 (matches legacy shadowed buttons).
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TakingControlIntroSecondTestCardView: View {
    let title: String
    let subtitle: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 12) {
                Text(title)
                    .font(LoginDesignSystem.Typography.lexendMedium(size: 16))
                    .foregroundStyle(.primary)

                Spacer(minLength: 8)

                Text(subtitle)
                    .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: .black.opacity(0.18), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("AUDIT card") {
    TakingControlIntroSecondTestCardView(
        title: TakingControlIntroSecondLocalization.auditTitle.localized,
        subtitle: TakingControlIntroSecondLocalization.auditSubtitle.localized,
        onTap: {}
    )
    .padding()
    .background(Color("AppBackGroundColor"))
}
#endif
