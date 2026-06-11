//
//  TakingControlMenuButtonView.swift
//  Calmscient
//
//  Outlined course step button (Basic knowledge, Make a plan, etc.).
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TakingControlMenuButtonView: View {

    let item: TakingControlMenuItemPresentation
    let onTap: () -> Void

    private let brandPurple = LoginDesignSystem.ColorName.primaryGradientTop
    private let inactiveBorder = Color(red: 0.82, green: 0.82, blue: 0.84)

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(item.title)
                    .font(LoginDesignSystem.Typography.lexendLight(size: 16))
                    .foregroundStyle(item.isActive ? brandPurple : inactiveBorder)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if item.showsCheckmark {
                    Image("check")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(item.isActive ? brandPurple : inactiveBorder, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Active menu button") {
    TakingControlMenuButtonView(
        item: TakingControlMenuItemPresentation(id: 0, title: "Basic knowledge", isActive: true, showsCheckmark: false),
        onTap: {}
    )
    .padding()
}
#endif
