//
//  JournalEntryBottomChromeView.swift
//  Calmscient
//
//  Offline notice and primary “need to talk” action above the tab bar.
//
//  Vivek
//  18 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct JournalEntryBottomChromeView: View {

    var showOfflineBanner: Bool
    var offlineMessage: String
    var helpButtonTitle: String
    var onNeedToTalk: () -> Void

    var body: some View {

            Button(action: onNeedToTalk) {
                Text(helpButtonTitle)
                    .font(LoginDesignSystem.Typography.lexendSemiBold(size: 16))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(LoginDesignSystem.ColorName.loginGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

    }
}

@available(iOS 16.0, *)
#Preview("Bottom chrome online") {
    JournalEntryBottomChromeView(
        showOfflineBanner: false,
        offlineMessage: "",
        helpButtonTitle: "Need to talk with someone?".localized,
        onNeedToTalk: {}
    )
    .background(Color.gray.opacity(0.2))
}

