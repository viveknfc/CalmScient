//
//  ProgressOnCourseWorkViewModel.swift
//  Calmscient
//
//  State, API, and navigation for progress on course work (parity with `ProgressOnWorkMainViewController`).
//
//  Vivek
//  18 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class ProgressOnCourseWorkViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var summary = ProgressOnCourseWorkSummaryPresentation(
        title: "",
        percentageText: "0.0%",
        progress: 0,
        minLabel: "0.0%",
        maxLabel: "100%"
    )
    @Published private(set) var rows: [ProgressOnCourseWorkRowPresentation] = []
    @Published private(set) var isLoading = false

    private(set) var navigationChromeTitle: String = ""
    private(set) var courseColumnTitle: String = ""
    private(set) var completedColumnTitle: String = ""
    private(set) var needToTalkButtonTitle: String = ""

    private var courses: [PatientCourseWorkItem] = []
    private var anchorView: UIView? { hostViewController?.view }

    func onHostWillAppear() {
        reloadLocalizedStrings()
        fetchCourseProgress()
    }

    func reloadLocalizedStrings() {
        navigationChromeTitle = "Progress on course work".localized
        courseColumnTitle = "Course".localized
        completedColumnTitle = "% " + "Completed".localized
        needToTalkButtonTitle = "Need to talk with someone?".localized

        summary = ProgressOnCourseWorkSummaryPresentation(
            title: AppHelper.getLocalizeString(str: "DRINKING_CONTROL_Total_Course_Work_Completed"),
            percentageText: summary.percentageText,
            progress: summary.progress,
            minLabel: summary.minLabel,
            maxLabel: summary.maxLabel
        )
    }

    // MARK: - Navigation

    func openBack() {
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    func openCourse(at index: Int) {
        guard let nav = hostViewController?.navigationController else { return }
        guard courses.indices.contains(index) else { return }

        let host = ProgressOnCourseWorkDetailHostingController()
        host.configure(courses: courses, selectedIndex: index)
        nav.pushViewController(host, animated: true)
    }

    func openNeedToTalk() {
        guard let nav = hostViewController?.navigationController else { return }
        let storyboard = UIStoryboard(name: "NeedToTalkViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NeedToTalkViewController") as? NeedToTalkViewController
        vc?.title = "Emergency resources".localized
        guard let vc else { return }
        nav.pushViewController(vc, animated: true)
    }

    // MARK: - API

    func fetchCourseProgress() {
        guard NetworkMonitor.shared.isConnected else {
            NoInternetBanner.shared.openDetails()
            return
        }

        guard let loginResponse = ApplicationSharedInfo.shared.loginResponse,
              let host = hostViewController,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }

        isLoading = true
        rows = []
        anchorView?.showToastActivity()

        let params: [String: Any] = [
            "patientId": loginResponse.patientID,
        ]

        APIService.getPatientCourseWorkPercentageDetailsAPICalling(
            host,
            params: params,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleFetchResponse(response)
            }
        }
    }

    private func handleFetchResponse(_ response: AnyObject) {
        isLoading = false
        anchorView?.hideToastActivity()

        if let errorMessage = response as? String, errorMessage.hasPrefix("Error:") {
            anchorView?.showToast(message: errorMessage.replacingOccurrences(of: "Error: ", with: ""))
            applyEmptyState()
            return
        }

        guard let json = response as? [String: Any],
              let data = try? JSONSerialization.data(withJSONObject: json),
              let decoded = try? JSONDecoder().decode(PatientCourseWorkListResponse.self, from: data) else {
            anchorView?.showToast(message: "An Unknown error occured. Please check with Admin")
            applyEmptyState()
            return
        }

        let courseList = decoded.patientcourseWorkList ?? []
        courses = courseList

        let totalPercentage = courseList.reduce(Float(0)) { partial, course in
            partial + (course.completedPer ?? 0)
        }
        let average = courseList.isEmpty ? Float(0) : totalPercentage / Float(courseList.count)
        let averageText = CourseProgressFormatting.percentageText(average)

        summary = ProgressOnCourseWorkSummaryPresentation(
            title: AppHelper.getLocalizeString(str: "DRINKING_CONTROL_Total_Course_Work_Completed"),
            percentageText: averageText,
            progress: average / 100,
            minLabel: averageText,
            maxLabel: "100%"
        )

        rows = courseList.enumerated().map { index, course in
            let percentage = course.completedPer ?? 0
            return ProgressOnCourseWorkRowPresentation(
                id: course.id,
                title: course.courseName ?? "",
                percentageText: CourseProgressFormatting.rowPercentageText(percentage),
                courseIndex: index
            )
        }
    }

    private func applyEmptyState() {
        courses = []
        rows = []
        summary = ProgressOnCourseWorkSummaryPresentation(
            title: AppHelper.getLocalizeString(str: "DRINKING_CONTROL_Total_Course_Work_Completed"),
            percentageText: "0.0%",
            progress: 0,
            minLabel: "0.0%",
            maxLabel: "100%"
        )
    }

    #if DEBUG
    func applyPreviewState(
        summary: ProgressOnCourseWorkSummaryPresentation,
        rows: [ProgressOnCourseWorkRowPresentation],
        courses: [PatientCourseWorkItem] = CourseProgressPresentationPreviewData.sampleCourses
    ) {
        reloadLocalizedStrings()
        self.summary = summary
        self.rows = rows
        self.courses = courses
    }
    #endif
}
