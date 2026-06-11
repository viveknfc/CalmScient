//
//  TouchButterflyHowToView.swift
//  Calmscient
//
//  SwiftUI how-to steps for touch and the butterfly hug (parity with `TouchButterflyHug`).
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TouchButterflyHowToView: View {

    @ObservedObject var viewModel: TouchButterflyHugViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                Text(TouchButterflyHugPresentation.howToTitleKey.localized)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 18))
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                ScrollView {
                    TouchButterflyHowToTimelineSectionView(steps: TouchButterflyHugPresentation.howToSteps)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
                .padding(.bottom, 77)
            }

            TouchButterflyHowToBottomBarView(
                completeTitle: "Complete".localized,
                onBack: viewModel.openBack,
                onComplete: viewModel.completeTapped
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground).ignoresSafeArea())
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Touch butterfly how-to") {
    let viewModel = TouchButterflyHugViewModel()
    viewModel.applyPreviewState()
    return TouchButterflyHowToView(viewModel: viewModel)
}
#endif

