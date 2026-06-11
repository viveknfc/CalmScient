//
//  MySmokingHabitHeaderSectionView.swift
//  Calmscient
//
//  Purple header and stage question for My Smoking Habit.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MySmokingHabitHeaderSectionView: View {

    @ObservedObject var viewModel: MySmokingHabitViewModel

    private let bodyFont = LoginDesignSystem.Typography.lexendLight(size: 15)

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            BasicStandardDrinkHeaderView(title: viewModel.headerTitle)

            Text(viewModel.stageQuestion)
                .font(bodyFont)
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("My smoking habit header") {
    let viewModel = MySmokingHabitViewModel()
    viewModel.applyPreviewState()
    return MySmokingHabitHeaderSectionView(viewModel: viewModel)
        .padding(.horizontal, 20)
}
#endif
