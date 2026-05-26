//
//  QuitSymptomModalGoBackButtonView.swift
//  Calmscient
//
//  Go back capsule button for ready-to-quit symptom modals.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct QuitSymptomModalGoBackButtonView: View {

    let title: String
    let onTap: () -> Void

    private let borderColor = Color(hex: "#6E6BB3")

    var body: some View {
        HStack {
            Spacer()
            Button(action: onTap) {
                Text(title)
                    .font(LoginDesignSystem.Typography.lexendMedium(size: 14))
                    .foregroundStyle(borderColor)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(borderColor, lineWidth: 2)
                    )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 8)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Quit symptom go back button") {
    QuitSymptomModalGoBackButtonView(title: "Go back", onTap: {})
        .padding()
}
#endif
