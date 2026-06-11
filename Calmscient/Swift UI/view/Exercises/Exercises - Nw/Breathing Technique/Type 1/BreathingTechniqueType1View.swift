//
//  BreathingTechniqueType1View.swift
//  Calmscient
//
//  SwiftUI 4-7-8 breathing exercise detail (parity with legacy `BreathingTechniqueType1`).
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct BreathingTechniqueType1View: View {

    @ObservedObject var viewModel: BreathingTechniqueType1ViewModel

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

                stepsSection

                BreathingTechniqueType1VideoSectionView(viewModel: viewModel)

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

    private var stepsSection: some View {
        BreathingTechniqueType1StepsSectionView(steps: viewModel.steps)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("4-7-8 breathing exercise") {
    let viewModel = BreathingTechniqueType1ViewModel()
    viewModel.applyPreviewState()
    return BreathingTechniqueType1View(viewModel: viewModel)
}
#endif
