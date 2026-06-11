//
//  ProgressOnCourseWorkSummaryCardView.swift
//  Calmscient
//
//  Total or per-course progress summary card.
//
//  Vivek
//  18 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ProgressOnCourseWorkSummaryCardView: View {

    let presentation: ProgressOnCourseWorkSummaryPresentation

    private let titleColor = Color("424242Color")
    private let cardBackground = Color("AppViewContentColor")

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(presentation.title)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                .foregroundStyle(titleColor)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            ProgressOnCourseWorkProgressBarView(
                progress: presentation.progress,
                leadingLabel: presentation.minLabel,
                trailingLabel: presentation.maxLabel
            )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(cardBackground)
                .progressOnCourseWorkCardShadow()
        )
        
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Summary card") {
    ProgressOnCourseWorkSummaryCardView(
        presentation: CourseProgressPresentationPreviewData.summary()
    )
    .padding()
    .background(Color("AppBackGroundColor"))
}
#endif
