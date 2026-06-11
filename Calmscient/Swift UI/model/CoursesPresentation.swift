//
//  CoursesPresentation.swift
//  Calmscient
//
//  Presentation models for the courses lesson list (parity with `CoursesViewController`).
//
//  Vivek
//  19 May 2026
//

import Foundation

// MARK: - Course kind

enum CoursesKind: Equatable {
    case managingAnxiety
    case changingStressResponse

    init(courseID: Int) {
        self = courseID == 3 ? .changingStressResponse : .managingAnxiety
    }

    var courseID: Int {
        switch self {
        case .managingAnxiety: return 2
        case .changingStressResponse: return 3
        }
    }

    /// Query parameter value for the web lesson URL.
    var courseNameKey: String {
        switch self {
        case .managingAnxiety: return "managingAnxiety"
        case .changingStressResponse: return "changingYourResponseToStress"
        }
    }

    var webViewIndex: Int { courseID }

    var usesWhiteChapterTitles: Bool {
        self == .managingAnxiety
    }
}

// MARK: - Row models

struct CourseChapterPresentation: Identifiable, Equatable {
    let id: Int
    let chapterId: Int
    let lessonId: Int
    let title: String
    let imageURLString: String
    let isCompleted: Bool

    init(chapter: CourseChapter, lessonId: Int) {
        id = chapter.chapterId
        chapterId = chapter.chapterId
        self.lessonId = lessonId
        title = chapter.chapterName
        imageURLString = chapter.imageUrl
        isCompleted = chapter.isCourseCompleted != 0
    }

    #if DEBUG
    init(
        id: Int,
        chapterId: Int,
        lessonId: Int,
        title: String,
        imageURLString: String,
        isCompleted: Bool
    ) {
        self.id = id
        self.chapterId = chapterId
        self.lessonId = lessonId
        self.title = title
        self.imageURLString = imageURLString
        self.isCompleted = isCompleted
    }
    #endif
}

struct CourseLessonRowPresentation: Identifiable, Equatable {
    let id: Int
    let lessonId: Int
    let title: String
    let chapters: [CourseChapterPresentation]

    init(lesson: CourseLesson) {
        id = lesson.lessonId
        lessonId = lesson.lessonId
        title = lesson.lessonName
        chapters = lesson.chapters.map { CourseChapterPresentation(chapter: $0, lessonId: lesson.lessonId) }
    }
}

// MARK: - URL builder

enum CoursesLessonURLBuilder {

    static func webLessonURL(
        courseNameKey: String,
        lessonId: Int,
        chapterId: Int,
        languageName: String,
        darkTheme: Int
    ) -> String {
        let language = String(languageName.prefix(2)).lowercased()
        let darkThemeValue = darkTheme == 0 ? "false" : "true"
        return "\(APIService.Url4Courses)?courseName=\(courseNameKey)&lessonId=\(lessonId)&chapterId=\(chapterId)&language=\(language)&darkMode=\(darkThemeValue)"
    }
}

#if DEBUG
enum CoursesPresentationPreviewData {

    static let sampleLessons: [CourseLessonRowPresentation] = [
        CourseLessonRowPresentation(
            id: 1,
            lessonId: 1,
            title: "Introduction",
            chapters: [
                CourseChapterPresentation(
                    id: 1,
                    chapterId: 1,
                    lessonId: 1,
                    title: "Welcome",
                    imageURLString: "",
                    isCompleted: true
                ),
                CourseChapterPresentation(
                    id: 2,
                    chapterId: 2,
                    lessonId: 1,
                    title: "Getting started",
                    imageURLString: "",
                    isCompleted: false
                ),
            ]
        ),
    ]
}

extension CourseLessonRowPresentation {
    init(id: Int, lessonId: Int, title: String, chapters: [CourseChapterPresentation]) {
        self.id = id
        self.lessonId = lessonId
        self.title = title
        self.chapters = chapters
    }
}
#endif
