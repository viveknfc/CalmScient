//
//  QuitSymptomModalCloseButtonView.swift
//  Calmscient
//
//  Close control for ready-to-quit symptom modals.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct QuitSymptomModalCloseButtonView: View {

    let onClose: () -> Void

    var body: some View {
        HStack {
            Spacer()
            Button(action: onClose) {
                if let ui = UIImage(named: "closeIcon") {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 25))
                        .foregroundStyle(Color(hex: "#6E6BB3"))
                }
            }
            .buttonStyle(.plain)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Quit symptom close button") {
    QuitSymptomModalCloseButtonView(onClose: {})
        .padding()
}
#endif
