//
//  CourseProgressPresentation.swift
//  Calmscient
//
//  API models and UI presentation for progress on course work screens.
//
//  Vivek
//  18 May 2026
//

import Foundation

// MARK: - API

struct PatientCourseWorkListResponse: Decodable {
    let patientcourseWorkList: [PatientCourseWorkItem]?
}

struct PatientCourseWorkItem: Decodable, Identifiable, Hashable {
    var id: String { courseName ?? UUID().uuidString }
    let courseName: String?
    let completedPer: Float?
    let sectionsList: [PatientCourseWorkSection]?
}

struct PatientCourseWorkSection: Decodable, Identifiable, Hashable {
    var id: String { sectionName ?? UUID().uuidString }
    let sectionName: String?
    let completions: String?
    let subSectionList: [PatientCourseWorkSubSection]?
}

struct PatientCourseWorkSubSection: Decodable, Hashable {
    let subSectionName: String?
    let completion: String?
}

// MARK: - Presentation

struct ProgressOnCourseWorkSummaryPresentation: Equatable {
    let title: String
    let percentageText: String
    let progress: Float
    let minLabel: String
    let maxLabel: String
}

struct ProgressOnCourseWorkRowPresentation: Identifiable, Equatable {
    let id: String
    let title: String
    let percentageText: String
    let courseIndex: Int
}

struct ProgressOnCourseWorkSubsectionPresentation: Identifiable, Equatable {
    let id: String
    let title: String
    let percentageText: String
}

struct ProgressOnCourseWorkSectionPresentation: Identifiable, Equatable {
    let id: String
    let title: String
    let titlePercentageText: String
    let subsections: [ProgressOnCourseWorkSubsectionPresentation]
    var isExpanded: Bool
}

enum CourseProgressFormatting {

    static func percentageText(_ value: Float) -> String {
        String(format: "%.1f%%", value)
    }

    static func rowPercentageText(_ value: Float) -> String {
        "\(value)%"
    }

    static func sectionPercentageText(_ value: String) -> String {
        "\(value) %"
    }
}

#if DEBUG
enum CourseProgressPresentationPreviewData {

    static let sampleCourses: [PatientCourseWorkItem] = [
        PatientCourseWorkItem(
            courseName: "Changing your response to stress",
            completedPer: 0,
            sectionsList: [
                PatientCourseWorkSection(
                    sectionName: "Introduction",
                    completions: "0%",
                    subSectionList: [
                        PatientCourseWorkSubSection(subSectionName: "Welcome", completion: "0")
                    ]
                )
            ]
        ),
        PatientCourseWorkItem(
            courseName: "Managing anxiety",
            completedPer: 0,
            sectionsList: [
                PatientCourseWorkSection(
                    sectionName: "Getting started",
                    completions: "0%",
                    subSectionList: [
                        PatientCourseWorkSubSection(subSectionName: "Overview", completion: "0")
                    ]
                )
            ]
        ),
    ]

    static func mainRows() -> [ProgressOnCourseWorkRowPresentation] {
        sampleCourses.enumerated().map { index, course in
            ProgressOnCourseWorkRowPresentation(
                id: course.id,
                title: course.courseName ?? "",
                percentageText: CourseProgressFormatting.rowPercentageText(course.completedPer ?? 0),
                courseIndex: index
            )
        }
    }

    static func summary() -> ProgressOnCourseWorkSummaryPresentation {
        ProgressOnCourseWorkSummaryPresentation(
            title: "Total Course Work Completed",
            percentageText: "0.0%",
            progress: 0,
            minLabel: "0.0%",
            maxLabel: "100%"
        )
    }

    static func detailSections() -> [ProgressOnCourseWorkSectionPresentation] {
        guard let sections = sampleCourses.first?.sectionsList else { return [] }
        return sections.map { section in
            let subtitles = section.subSectionList ?? []
            return ProgressOnCourseWorkSectionPresentation(
                id: section.id,
                title: section.sectionName ?? "",
                titlePercentageText: CourseProgressFormatting.sectionPercentageText(section.completions ?? "0%"),
                subsections: subtitles.enumerated().map { index, item in
                    ProgressOnCourseWorkSubsectionPresentation(
                        id: "\(section.id)-\(index)",
                        title: item.subSectionName ?? "",
                        percentageText: "\(item.completion ?? "0")%"
                    )
                },
                isExpanded: false
            )
        }
    }
}
#endif
