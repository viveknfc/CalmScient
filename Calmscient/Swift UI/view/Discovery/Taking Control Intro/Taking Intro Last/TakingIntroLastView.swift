//
//  TakingIntroLastView.swift
//  Calmscient
//
//  SwiftUI last step of Taking Control intro (parity with `TakingIntroLastVC`).
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TakingIntroLastView: View {

    @ObservedObject var viewModel: TakingIntroLastViewModel

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color("AppBackGroundColor")
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TakingIntroLastThankYouHeaderView(attributedText: viewModel.thankYouAttributed)
                        .padding(.top, 8)

                    TakingIntroLastActionButton(
                        title: viewModel.drinkingCoachButtonTitle,
                        action: { viewModel.openDrinkingCoach() }
                    )

                    Text(viewModel.dustSectionText)
                        .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    TakingIntroLastActionButton(
                        title: viewModel.notifyPcpButtonTitle,
                        action: { viewModel.openNotifyPCP() }
                    )

                    Text(viewModel.smokingSectionText)
                        .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    TakingIntroLastActionButton(
                        title: viewModel.smokingCoachButtonTitle,
                        action: { viewModel.openSmokingCoach() }
                    )

                    Text(viewModel.footerText)
                        .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    TakingIntroLastCheckboxRowView(
                        label: viewModel.checkboxLabelText,
                        isOn: $viewModel.isDoNotShowAgainOn,
                        onToggle: { viewModel.setDoNotShowAgain(isOn: $0) }
                    )
                    .padding(.top, 16)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)

            TakingIntroLastFabBackButton {
                viewModel.openFloatingBack()
            }
            .padding(.leading, 30)
            .padding(.bottom, 12)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Taking intro last — full page") {
    let vm = TakingIntroLastViewModel()
    vm.applyPreviewState()
    return TakingIntroLastView(viewModel: vm)
}
#endif
