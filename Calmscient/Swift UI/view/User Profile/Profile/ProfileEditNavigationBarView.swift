//
//  ProfileEditNavigationBarView.swift
//  Calmscient
//
//  Date: May 14, 2026
//  Custom top bar (back + title) for the patient profile edit SwiftUI screen.
//
//  Vivek
//  14 May 2026
//
import SwiftUI

@available(iOS 16.0, *)
struct ProfileEditNavigationBarView: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Text(title)
                .font(LoginDesignSystem.Typography.lexendBold(size: 18))
                .foregroundStyle(Color.black)

            HStack {
                MedicationNavigationBackButton(onBack: onBack)
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
