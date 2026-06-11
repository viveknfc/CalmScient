//
//  MyDrinkingHabitHeaderSectionView.swift
//  Calmscient
//
//  Header, moderate drinking definition, and calculator button.
//
//  Vivek
//  25 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MyDrinkingHabitHeaderSectionView: View {

    @ObservedObject var viewModel: MyDrinkingHabitViewModel

    private let bodyFont = LoginDesignSystem.Typography.lexendLight(size: 15)
    private let bodyColor = Color.primary

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            BasicStandardDrinkHeaderView(title: viewModel.headerTitle)

            Text(viewModel.habitQuestion)
                .font(bodyFont)
                .foregroundStyle(bodyColor)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Text(viewModel.moderateDefinitionIntro)
                .font(bodyFont)
                .foregroundStyle(bodyColor)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 5) {
                MyDrinkingHabitModerateLimitRowView(
                    label: viewModel.menLabel,
                    value: viewModel.menLimit
                )
                MyDrinkingHabitModerateLimitRowView(
                    label: viewModel.womenLabel,
                    value: viewModel.womenLimit
                )
            }

            Text(viewModel.knowCountsPrompt)
                .font(bodyFont)
                .foregroundStyle(bodyColor)
                .fixedSize(horizontal: false, vertical: true)

            LoginGradientButton(
                title: viewModel.calculatorButtonTitle,
                action: viewModel.openDrinkCountsCalculator
            )
            .padding(.horizontal, 0)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("My drinking habit header") {
    let viewModel = MyDrinkingHabitViewModel()
    viewModel.applyPreviewState()
    return MyDrinkingHabitHeaderSectionView(viewModel: viewModel)
        .padding(.horizontal, 20)
}
#endif
