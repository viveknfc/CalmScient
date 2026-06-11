//
//  DiaphragmaticBreathingView.swift
//  Calmscient
//
//  SwiftUI diaphragmatic breathing exercise detail (parity with legacy `DiagraphicBreathe`).
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct DiaphragmaticBreathingView: View {

    @ObservedObject var viewModel: DiaphragmaticBreathingViewModel

    private let textColor = Color("lineChartLabelColor")

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(viewModel.topDescription)
                    .font(LoginDesignSystem.Typography.lexendLight(size: 15))
                    .foregroundStyle(textColor)
                    .fixedSize(horizontal: false, vertical: true)

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
#Preview("Diaphragmatic breathing exercise") {
    let viewModel = DiaphragmaticBreathingViewModel()
    viewModel.applyPreviewState()
    return DiaphragmaticBreathingView(viewModel: viewModel)
}
#endif
