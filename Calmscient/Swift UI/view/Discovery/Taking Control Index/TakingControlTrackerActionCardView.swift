//
//  TakingControlTrackerActionCardView.swift
//  Calmscient
//
//  Drink tracker / Events tracker quick-action tiles on the Drinking tab.
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TakingControlTrackerActionCardView: View {

    let title: String
    let imageName: String
    let onTap: () -> Void

    private let cardBackground = Color(red: 0.96, green: 0.96, blue: 0.97)
    private let labelGray = Color(red: 0.55, green: 0.55, blue: 0.58)

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                if let ui = UIImage(named: imageName) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 44)
                } else {
                    Image(systemName: imageName)
                        .font(.system(size: 32))
                        .foregroundStyle(labelGray)
                }

                Text(title)
                    .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                    .foregroundStyle(labelGray)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(cardBackground)
            )
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Tracker card") {
    TakingControlTrackerActionCardView(
        title: "Drink tracker",
        imageName: "alcoholImage",
        onTap: {}
    )
    .padding()
    .frame(width: 180)
}
#endif
