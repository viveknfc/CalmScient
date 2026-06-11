//
//  CoursesLessonRowView.swift
//  Calmscient
//
//  Single lesson section with title and horizontally scrolling chapter cards.
//
//  Vivek
//  19 May 2026
//

import SwiftUI

struct CoursesLessonRowView: View {

    let lesson: CourseLessonRowPresentation
    let usesWhiteChapterTitle: Bool
    let onChapterTap: (CourseChapterPresentation) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(lesson.title)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 16))
                .foregroundStyle(Color("424242Color"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(lesson.chapters) { chapter in
                        CoursesChapterCardView(
                            chapter: chapter,
                            usesWhiteChapterTitle: usesWhiteChapterTitle,
                            onTap: { onChapterTap(chapter) }
                        )
                    }
                }
            }
            .frame(height: 120)
        }
        .padding(.horizontal, 16)
        .frame(height: 160, alignment: .top)
    }
}

#if DEBUG
#Preview("Courses lesson row") {
    CoursesLessonRowView(
        lesson: CoursesPresentationPreviewData.sampleLessons[0],
        usesWhiteChapterTitle: true,
        onChapterTap: { _ in }
    )
    .background(Color("AppBackGroundColor"))
}
#endif
