//
//  ConSub1DidYouKnowCloseButtonView.swift
//  Calmscient
//
//  Close control for the Did you know alert (parity with `AlertVC` close button).
//
//  Vivek
//  25 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ConSub1DidYouKnowCloseButtonView: View {

    let onClose: () -> Void

    var body: some View {
        Button(action: onClose) {
            if let ui = UIImage(named: "closeIcon") {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
            } else {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 25))
                    .foregroundStyle(Color.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("ConSub1 alert close button") {
    ConSub1DidYouKnowCloseButtonView(onClose: {})
        .padding()
}
#endif
