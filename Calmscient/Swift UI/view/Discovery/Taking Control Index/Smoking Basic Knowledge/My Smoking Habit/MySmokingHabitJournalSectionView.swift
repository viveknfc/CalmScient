//
//  MySmokingHabitJournalSectionView.swift
//  Calmscient
//
//  Weekly summary journal prompt and Yes action for My Smoking Habit.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MySmokingHabitJournalSectionView: View {

    @ObservedObject var viewModel: MySmokingHabitViewModel

    private let promptFont = LoginDesignSystem.Typography.lexendLight(size: 15)

    var body: some View {
        VStack(spacing: 20) {
            Text(viewModel.journalPrompt)
                .font(promptFont)
                .foregroundStyle(Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: viewModel.yesTapped) {
                Text(viewModel.yesButtonTitle)
                    .font(LoginDesignSystem.Typography.lexendMedium(size: 14))
                    .foregroundStyle(Color.white)
                    .frame(width: 121, height: 48)
                    .background(
                        Capsule(style: .continuous)
                            .fill(LoginDesignSystem.ColorName.loginGradient)
                    )
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Journal section") {
    let viewModel = MySmokingHabitViewModel()
    viewModel.applyPreviewState()
    return MySmokingHabitJournalSectionView(viewModel: viewModel)
        .padding(.horizontal, 20)
}
#endif
