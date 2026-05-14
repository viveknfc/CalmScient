//
// Vivek
// Date: May 14, 2026
//
//  ProfileEditNavigationBarView.swift
//  Calmscient
//
//  Custom top bar (back + title) for the patient profile edit SwiftUI screen.
//

import SwiftUI

@available(iOS 16.0, *)
struct ProfileEditNavigationBarView: View {
    let title: String
    let onBack: () -> Void

    private let backFill = Color(red: 0.93, green: 0.9, blue: 0.98)
    private let backIcon = Color(red: 0.35, green: 0.22, blue: 0.62)

    var body: some View {
        ZStack {
            Text(title)
                .font(LoginDesignSystem.Typography.lexendBold(size: 18))
                .foregroundStyle(Color.black)

            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(backIcon)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(backFill))
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview {
    ProfileEditNavigationBarView(title: "Profile", onBack: {})
}
#endif
