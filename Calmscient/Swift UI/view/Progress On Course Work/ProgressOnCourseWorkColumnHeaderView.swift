//
//  ProgressOnCourseWorkColumnHeaderView.swift
//  Calmscient
//
//  Column titles for course list (Course / % Completed).
//
//  Vivek
//  18 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ProgressOnCourseWorkColumnHeaderView: View {

    let courseTitle: String
    let completedTitle: String

    private let titleColor = Color("424242Color")

    var body: some View {
        HStack {
            Text(courseTitle)
                .font(LoginDesignSystem.Typography.lexendMedium(size: 14))
                .foregroundStyle(titleColor)

            Spacer()

            Text(completedTitle)
                .font(LoginDesignSystem.Typography.lexendMedium(size: 14))
                .foregroundStyle(titleColor)
        }
        .padding(.horizontal, 24)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Column header") {
    ProgressOnCourseWorkColumnHeaderView(
        courseTitle: "Course",
        completedTitle: "% Completed"
    )
}
#endif
