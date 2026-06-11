//
//  DayFeedbackJournalCard.swift
//  Calmscient
//
//  Journal title + editor in one card.
//
//  Vivek
//  14 May 2026
//
import SwiftUI
import UIKit

@available(iOS 16.0, *)
struct DayFeedbackJournalCard: View {
    @ObservedObject var viewModel: UserIntroDayFeedbackViewModel

    var body: some View {
        DayFeedbackFeedbackCard {
            VStack(alignment: .leading, spacing: 12) {
                journalTitleView()

                ZStack(alignment: .bottomTrailing) {
                    TextEditor(text: Binding(
                        get: { viewModel.journalText },
                        set: { viewModel.journalChanged($0) }
                    ))
                    .frame(minHeight: 120)
                    .padding(10)
                    .background(Color.gray.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    )

                    Text("\(min(viewModel.journalText.count, 2000))/2000")
                        .font(.caption2)
                        .foregroundStyle(LoginDesignSystem.ColorName.footerGray)
                        .padding(8)
                }
            }
        }
    }

    private func journalTitleView() -> some View {
        let labelText = (viewModel.templateData?.journalData?.journalKey ?? "Daily journal").localized
        return Text(labelText)
            .font(LoginDesignSystem.Typography.lexendMedium(size: 16))
            .foregroundStyle(LoginDesignSystem.ColorName.titleGray)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Journal Card") {
    let vm = UserIntroDayFeedbackViewModel()
    vm.journalText = "Sample journal note for quick UI tuning."
    return DayFeedbackJournalCard(viewModel: vm)
        .padding()
        .background(Color(red: 0.96, green: 0.96, blue: 0.97))
}
#endif
