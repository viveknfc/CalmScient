//
//  MindfulBreathingView.swift
//  Calmscient
//
//  SwiftUI mindful breathing exercise detail (parity with legacy `MindfulBreathing`).
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MindfulBreathingView: View {

    @ObservedObject var viewModel: MindfulBreathingViewModel

    private let textColor = Color("lineChartLabelColor")

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BreathingTechniqueType1PreparationCardView(
                    header: viewModel.preparationHeader,
                    bodyText: viewModel.preparationBody
                )

                Text(viewModel.stepsSubtitle)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                    .foregroundStyle(textColor)
                    .fixedSize(horizontal: false, vertical: true)

                BreathingTechniqueType1StepsSectionView(steps: viewModel.steps)

                BreathingExerciseVideoSectionView(viewModel: viewModel)

                Text(viewModel.bottomDescription)
                    .font(LoginDesignSystem.Typography.lexendLight(size: 15))
                    .foregroundStyle(textColor)
                    .fixedSize(horizontal: false, vertical: true)

                BreathingTechniqueType1CompleteButtonView(
                    title: viewModel.completeButtonTitle,
                    isEnabled: viewModel.isCompleteEnabled,
                    action: viewModel.completeTapped
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground).ignoresSafeArea())
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Mindful breathing exercise") {
    let viewModel = MindfulBreathingViewModel()
    viewModel.applyPreviewState()
    return MindfulBreathingView(viewModel: viewModel)
}
#endif
