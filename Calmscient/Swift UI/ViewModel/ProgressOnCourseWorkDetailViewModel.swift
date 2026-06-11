//
//  ProgressOnCourseWorkDetailViewModel.swift
//  Calmscient
//
//  State and navigation for a single course progress detail (parity with `ProgressOnWorkDetailViewController`).
//
//  Vivek
//  18 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class ProgressOnCourseWorkDetailViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var summary = ProgressOnCourseWorkSummaryPresentation(
        title: "",
        percentageText: "0.0%",
        progress: 0,
        minLabel: "0.0%",
        maxLabel: "100%"
    )
    @Published private(set) var sections: [ProgressOnCourseWorkSectionPresentation] = []

    private(set) var navigationChromeTitle: String = ""
    private(set) var sectionsColumnTitle: String = ""
    private(set) var completedColumnTitle: String = ""
    private(set) var needToTalkButtonTitle: String = ""

    private var courses: [PatientCourseWorkItem] = []
    private var selectedIndex = 0

    func configure(courses: [PatientCourseWorkItem], selectedIndex: Int) {
        self.courses = courses
        self.selectedIndex = selectedIndex
        rebuildPresentation()
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
        rebuildPresentation()
    }

    func reloadLocalizedStrings() {
        navigationChromeTitle = "Progress on course work".localized
        sectionsColumnTitle = "Sections".localized
        completedColumnTitle = "% " + "Completed".localized
        needToTalkButtonTitle = "Need to talk with someone?".localized
    }

    func toggleSection(_ sectionID: String) {
        guard let index = sections.firstIndex(where: { $0.id == sectionID }) else { return }
        sections[index].isExpanded.toggle()
    }

    // MARK: - Navigation

    func openBack() {
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    func openNeedToTalk() {
        guard let nav = hostViewController?.navigationController else { return }
        let storyboard = UIStoryboard(name: "NeedToTalkViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NeedToTalkViewController") as? NeedToTalkViewController
        vc?.title = "Emergency resources".localized
        guard let vc else { return }
        nav.pushViewController(vc, animated: true)
    }

    // MARK: - Presentation

    private func rebuildPresentation() {
        guard courses.indices.contains(selectedIndex) else {
            sections = []
            return
        }

        let course = courses[selectedIndex]
        let percentage = course.completedPer ?? 0
        let percentageText = CourseProgressFormatting.percentageText(percentage)

        summary = ProgressOnCourseWorkSummaryPresentation(
            title: course.courseName ?? "",
            percentageText: percentageText,
            progress: percentage / 100,
            minLabel: percentageText,
            maxLabel: "100%"
        )

        let existingExpansion = Dictionary(uniqueKeysWithValues: sections.map { ($0.id, $0.isExpanded) })
        let sectionList = course.sectionsList ?? []

        sections = sectionList.map { section in
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
                isExpanded: existingExpansion[section.id] ?? false
            )
        }
    }

    #if DEBUG
    func applyPreviewState(
        summary: ProgressOnCourseWorkSummaryPresentation,
        sections: [ProgressOnCourseWorkSectionPresentation]
    ) {
        reloadLocalizedStrings()
        self.summary = summary
        self.sections = sections
    }
    #endif
}
