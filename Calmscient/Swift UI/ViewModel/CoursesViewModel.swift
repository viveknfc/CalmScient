//
//  CoursesViewModel.swift
//  Calmscient
//
//  State, API, and navigation for course lessons (parity with `CoursesViewController`).
//
//  Vivek
//  19 May 2026
//

import Foundation
import SwiftUI
import UIKit

@MainActor
final class CoursesViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var lessons: [CourseLessonRowPresentation] = []
    @Published private(set) var isLoading = false

    private(set) var navigationChromeTitle: String = ""
    private(set) var coursesKind: CoursesKind = .managingAnxiety

    private var courseSessionID = ""
    private var languageName = ""
    private var darkTheme = 0

    private var anchorView: UIView? { hostViewController?.view }

    func configure(courseID: Int, navigationTitle: String) {
        coursesKind = CoursesKind(courseID: courseID)
        navigationChromeTitle = navigationTitle
    }

    func onHostWillAppear() {
        fetchCourses()
    }

    // MARK: - Navigation

    func openBack() {
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    func openGlossary() {
        guard let host = hostViewController else { return }
        GlossaryNavigation.push(from: host)
    }

    func openChapter(_ chapter: CourseChapterPresentation) {
        guard !courseSessionID.isEmpty else { return }
        guard let host = hostViewController else { return }

        let baseURL = CoursesLessonURLBuilder.webLessonURL(
            courseNameKey: coursesKind.courseNameKey,
            lessonId: chapter.lessonId,
            chapterId: chapter.chapterId,
            languageName: languageName,
            darkTheme: darkTheme
        )
        let fullURLString = "\(baseURL)&sessionId=\(courseSessionID)"
        
        print("viv the full url reached here")

        let presentation = WebViewLessonPresentation(
            urlString: fullURLString,
            courseIndex: coursesKind.webViewIndex,
            pageTitle: coursesKind == .changingStressResponse ? chapter.title : "",
            initialNavigationTitle: coursesKind == .changingStressResponse ? nil : chapter.title
        )
        WebViewLessonNavigation.push(presentation: presentation, from: host)
    }

    // MARK: - API

    func fetchCourses() {
        guard NetworkMonitor.shared.isConnected else {
            NoInternetBanner.shared.openDetails()
            return
        }

        guard let loginResponse = ApplicationSharedInfo.shared.loginResponse,
              let host = hostViewController else {
            return
        }

        isLoading = true
        lessons = []
        anchorView?.showToastActivity()

        let params: [String: Any] = [
            "patientId": loginResponse.patientID,
            "clientId": loginResponse.clientID,
            "patientLocationId": loginResponse.patientLocationID,
            "courseId": coursesKind.courseID,
        ]

        APIService.getPatientCourseIndexAPICalling(
            host,
            params: params,
            method: "POST",
            accessToken: ApplicationSharedInfo.shared.tokenResponse?.accessToken ?? "",
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
            return
        }

        guard let json = response as? [String: Any],
              let data = try? JSONSerialization.data(withJSONObject: json),
              let decoded = try? JSONDecoder().decode(UserCoursesData.self, from: data) else {
            anchorView?.showToast(message: "An Unknown error occured. Please check with Admin".localized)
            return
        }

        if decoded.statusResponse.responseCode != 200 {
            anchorView?.showToast(message: decoded.statusResponse.responseMessage)
            return
        }

        courseSessionID = decoded.patientSessionDetails.userSessionID
        languageName = decoded.patientSessionDetails.languageName
        darkTheme = decoded.patientSessionDetails.darkTheme
        lessons = decoded.coursesList.map { CourseLessonRowPresentation(lesson: $0) }
    }

    #if DEBUG
    func applyPreviewState(
        lessons: [CourseLessonRowPresentation],
        kind: CoursesKind = .managingAnxiety,
        title: String = "Managing anxiety"
    ) {
        coursesKind = kind
        navigationChromeTitle = title
        courseSessionID = "preview-session"
        languageName = "English"
        darkTheme = 0
        self.lessons = lessons
    }
    #endif
}

// MARK: - Navigation

enum CoursesNavigation {

    static func push(
        courseID: Int,
        title: String,
        from host: UIViewController,
        animated: Bool = true
    ) {
        guard let nav = host.navigationController else { return }

        let coursesHost = CoursesHostingController()
        coursesHost.configure(courseID: courseID, navigationTitle: title)
        nav.pushViewController(coursesHost, animated: animated)
    }
}
