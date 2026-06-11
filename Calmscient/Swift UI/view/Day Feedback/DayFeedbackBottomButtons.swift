//
//  DayFeedbackBottomButtons.swift
//  Calmscient
//
//  Save + optional Skip bar (used with ScrollView safeAreaInset).
//
//  Vivek
//  14 May 2026
//
import SwiftUI
import UIKit

@available(iOS 16.0, *)
struct DayFeedbackBottomButtons: View {
    @ObservedObject var viewModel: UserIntroDayFeedbackViewModel

    var body: some View {
        VStack(spacing: 12) {
            LoginGradientButton(
                title: AppHelper.getLocalizeString(str: "Save"),
                isEnabled: !viewModel.isFetching,
                action: { viewModel.save() }
            )
            if !viewModel.hideSkipButton {
                Button(action: { viewModel.skip() }) {
                    Text(AppHelper.getLocalizeString(str: "Skip"))
                        .font(LoginDesignSystem.Typography.lexendSemiBold(size: 17))
                        .foregroundStyle(Color(uiColor: UIColor(named: "AppThemeColor") ?? UIColor.systemPurple))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            Capsule(style: .continuous)
                                .stroke(Color(uiColor: UIColor(named: "AppThemeColor") ?? UIColor.systemPurple), lineWidth: 2)
                        )
                        .contentShape(Capsule())
                }
                .padding(.horizontal, 20)
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(Color(red: 0.96, green: 0.96, blue: 0.97))
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Bottom Buttons") {
    let vm = UserIntroDayFeedbackViewModel()
    return DayFeedbackBottomButtons(viewModel: vm)
}
#endif
