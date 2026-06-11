//
//  BasicKnowledgeCompleteButtonView.swift
//  Calmscient
//
//  Floating Complete action for Basic Knowledge index (parity with `CapsuleButton1`).
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct BasicKnowledgeCompleteButtonView: View {

    let title: String
    let onTap: () -> Void

    var body: some View {
        HStack {
            Spacer()
            Button(action: onTap) {
                Text(title)
                    .font(LoginDesignSystem.Typography.lexendMedium(size: 14))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 20)
                    .frame(height: 40)
                    .background(
                        Capsule(style: .continuous)
                            .fill(LoginDesignSystem.ColorName.loginGradient)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Basic knowledge complete button") {
    BasicKnowledgeCompleteButtonView(title: "Complete".localized, onTap: {})
        .background(Color(white: 0.98))
}
#endif
