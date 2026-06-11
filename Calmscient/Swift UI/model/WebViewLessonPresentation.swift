//
//  WebViewLessonPresentation.swift
//  Calmscient
//
//  Presentation model for in-course web lessons (parity with `WebViewLessonViewController`).
//
//  Vivek
//  19 May 2026
//

import Foundation

struct WebViewLessonPresentation: Equatable {
    let urlString: String
    /// Course web-view index (`2` managing anxiety, `3` changing stress response).
    let courseIndex: Int
    /// Fallback title for message `1100` (changing stress uses `pageTitle` instead of nav title).
    let pageTitle: String
    /// Initial navigation bar title (managing anxiety sets chapter title on push).
    let initialNavigationTitle: String?

    init(
        urlString: String,
        courseIndex: Int,
        pageTitle: String = "",
        initialNavigationTitle: String? = nil
    ) {
        self.urlString = urlString
        self.courseIndex = courseIndex
        self.pageTitle = pageTitle
        self.initialNavigationTitle = initialNavigationTitle
    }

    var usesPageTitleForNavigation: Bool {
        courseIndex == 3
    }

    var shouldPopOnCourseComplete: Bool {
        courseIndex == 2 || courseIndex == 3
    }
}

#if DEBUG
enum WebViewLessonPresentationPreviewData {
    static let sampleManagingAnxiety = WebViewLessonPresentation(
        urlString: "https://example.com/lesson?courseName=managingAnxiety",
        courseIndex: 2,
        initialNavigationTitle: "Welcome"
    )

    static let sampleChangingStress = WebViewLessonPresentation(
        urlString: "https://example.com/lesson?courseName=changingYourResponseToStress",
        courseIndex: 3,
        pageTitle: "Chapter 1",
        initialNavigationTitle: nil
    )
}
#endif
