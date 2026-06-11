//
//  ConSub1SpotlightButtonView.swift
//  Calmscient
//
//  Spotlight tip button for Fatalities and injuries (parity with `ConSub1VC` alert).
//
//  Vivek
//  25 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ConSub1SpotlightButtonView: View {

    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image("spotlight")
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 35)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("DRINKING_CONTROL_ALERT_DUI_TITLE".localized)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("ConSub1 spotlight button") {
    ConSub1SpotlightButtonView(onTap: {})
        .padding()
}
#endif
