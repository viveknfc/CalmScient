//
//  ProgressOnCourseWorkDetailView.swift
//  Calmscient
//
//  SwiftUI per-course section progress (parity with `ProgressOnWorkDetailViewController`).
//
//  Vivek
//  18 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ProgressOnCourseWorkDetailView: View {

    @ObservedObject var viewModel: ProgressOnCourseWorkDetailViewModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ProgressOnCourseWorkSummaryCardView(presentation: viewModel.summary)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                    ProgressOnCourseWorkColumnHeaderView(
                        courseTitle: viewModel.sectionsColumnTitle,
                        completedTitle: viewModel.completedColumnTitle
                    )

                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.sections) { section in
                            ProgressOnCourseWorkSectionRowView(
                                section: section,
                                onToggle: { viewModel.toggleSection(section.id) }
                            )
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.bottom, 16)
            }

            if PatientLanguagePreference.shouldShowNeedToTalkButton() {
                LoginGradientButton(title: viewModel.needToTalkButtonTitle) {
                    viewModel.openNeedToTalk()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("AppBackGroundColor").ignoresSafeArea())
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Course detail") {
    let viewModel = ProgressOnCourseWorkDetailViewModel()
    viewModel.applyPreviewState(
        summary: ProgressOnCourseWorkSummaryPresentation(
            title: "Changing your response to stress",
            percentageText: "0.0%",
            progress: 0,
            minLabel: "0.0%",
            maxLabel: "100%"
        ),
        sections: CourseProgressPresentationPreviewData.detailSections()
    )
    return ProgressOnCourseWorkDetailView(viewModel: viewModel)
}
#endif
