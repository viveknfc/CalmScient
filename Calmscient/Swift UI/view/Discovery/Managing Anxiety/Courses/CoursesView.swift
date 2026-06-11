//
//  CoursesView.swift
//  Calmscient
//
//  SwiftUI courses lesson list (parity with legacy `CoursesViewController`).
//
//  Vivek
//  19 May 2026
//

import SwiftUI

struct CoursesView: View {

    @ObservedObject var viewModel: CoursesViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.lessons) { lesson in
                    CoursesLessonRowView(
                        lesson: lesson,
                        usesWhiteChapterTitle: viewModel.coursesKind.usesWhiteChapterTitles,
                        onChapterTap: { viewModel.openChapter($0) }
                    )
                }
            }
            .padding(.bottom, 16)
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
#Preview("Courses list") {
    let viewModel = CoursesViewModel()
    viewModel.applyPreviewState(
        lessons: CoursesPresentationPreviewData.sampleLessons,
        kind: .managingAnxiety,
        title: "Managing anxiety"
    )
    return CoursesView(viewModel: viewModel)
}
#endif
