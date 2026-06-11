//
//  DayFeedbackView.swift
//  Calmscient
//
//  Composes day-feedback cards; section UI lives in sibling files under Day Feedback/.
//
//  Vivek
//  14 May 2026
//
import SwiftUI

@available(iOS 16.0, *)
struct DayFeedbackView: View {

    @ObservedObject var viewModel: UserIntroDayFeedbackViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.96, green: 0.96, blue: 0.97)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                if viewModel.useLargeInlineGreeting {
                    Text(viewModel.greetingTitle)
                        .font(LoginDesignSystem.Typography.lexendMedium(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(LoginDesignSystem.ColorName.titleGray)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                        .frame(maxWidth: .infinity)
                }

                ScrollView {
                    VStack(spacing: 16) {
                        if viewModel.rows.isEmpty {
                            Text(AppHelper.getLocalizeString(str: "Please fill all mandatory fields."))
                                .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                                .foregroundStyle(LoginDesignSystem.ColorName.footerGray)
                                .padding()
                        } else {
                            ForEach(viewModel.rows, id: \.self) { row in
                                rowView(row)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                DayFeedbackBottomButtons(viewModel: viewModel)
            }
        }
        .onAppear { viewModel.onAppearRefreshIfNeeded() }
    }

    @ViewBuilder
    private func rowView(_ row: DayFeedbackRow) -> some View {
        switch row {
        case .mood:
            DayFeedbackMoodSelectionCard(viewModel: viewModel)
        case .focus:
            DayFeedbackFocusSelectionCard(viewModel: viewModel)
        case .sleep:
            DayFeedbackSleepCard(viewModel: viewModel)
        case .timeSpend:
            DayFeedbackTimeSpendCard(viewModel: viewModel)
        case .medicine:
            DayFeedbackMedicineCard(viewModel: viewModel)
        case .journal:
            DayFeedbackJournalCard(viewModel: viewModel)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Day feedback") {
    DayFeedbackView(viewModel: UserIntroDayFeedbackViewModel())
}
#endif
