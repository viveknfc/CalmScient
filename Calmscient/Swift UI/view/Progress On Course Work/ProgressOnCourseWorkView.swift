//
//  ProgressOnCourseWorkView.swift
//  Calmscient
//
//  SwiftUI progress on course work list (parity with `ProgressOnWorkMainViewController`).
//
//  Vivek
//  18 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ProgressOnCourseWorkView: View {

    @ObservedObject var viewModel: ProgressOnCourseWorkViewModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ProgressOnCourseWorkSummaryCardView(presentation: viewModel.summary)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                    ProgressOnCourseWorkColumnHeaderView(
                        courseTitle: viewModel.courseColumnTitle,
                        completedTitle: viewModel.completedColumnTitle
                    )

                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.rows) { row in
                            ProgressOnCourseWorkRowView(
                                title: row.title,
                                percentageText: row.percentageText,
                                onTap: { viewModel.openCourse(at: row.courseIndex) }
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
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Progress on course work") {
    let viewModel = ProgressOnCourseWorkViewModel()
    viewModel.applyPreviewState(
        summary: CourseProgressPresentationPreviewData.summary(),
        rows: CourseProgressPresentationPreviewData.mainRows()
    )
    return ProgressOnCourseWorkView(viewModel: viewModel)
}
#endif
