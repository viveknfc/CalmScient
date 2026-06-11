//
//  ScreeningQuestionsViewModel.swift
//  Calmscient
//
//  State, API, and navigation for screening questionnaire (parity with legacy `ScreeningQuestionsViewController`).
//
//  Vivek
//  15 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class ScreeningQuestionsViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    private(set) var selectedScreening: Screening?
    var onSubmissionSuccess: ((Screening?) -> Void)?

    @Published private(set) var questions: [QuestionnaireItem] = []
    @Published private(set) var pageNumber: Int = 0
    @Published private(set) var selectedAnswerIndices: [Int] = []
    @Published private(set) var isLoading = false
    @Published private(set) var showsBackwardButton = false
    @Published private(set) var showsForwardButton = true
    @Published private(set) var showsCompleteButton = false
    @Published private(set) var showsInfoButton = true

    private var patientAnswers: [PatientAnswer?] = []
    private var didShowInitialInfo = false
    private var hasFetchedQuestionnaire = false

    private var anchorView: UIView? { hostViewController?.view }

    var maxPage: Int { questions.count }

    var navigationChromeTitle: String {
        selectedScreening?.screeningType ?? ""
    }

    var screeningReminder: String {
        selectedScreening?.screeningReminder ?? ""
    }

    var currentQuestionText: String {
        guard questions.indices.contains(pageNumber) else { return "" }
        return questions[pageNumber].questionName
    }

    var currentOptions: [ScreeningQuestionOptionPresentation] {
        guard questions.indices.contains(pageNumber) else { return [] }
        let item = questions[pageNumber]
        let selectedIdx = selectedAnswerIndices.indices.contains(pageNumber)
            ? selectedAnswerIndices[pageNumber]
            : -1
        return item.answerResponse.enumerated().map { index, answer in
            ScreeningQuestionOptionPresentation(
                id: "\(pageNumber)-\(index)",
                label: answer.optionLabel,
                index: index,
                isSelected: index == selectedIdx
            )
        }
    }

    // MARK: - Configuration

    func configure(
        selectedScreening: Screening,
        onSubmissionSuccess: ((Screening?) -> Void)? = nil
    ) {
        self.selectedScreening = selectedScreening
        self.onSubmissionSuccess = onSubmissionSuccess
    }

    func onHostWillAppear() {
        if !didShowInitialInfo {
            didShowInitialInfo = true
            presentInformationAlert(
                title: "Information".localized,
                message: screeningReminder
            )
        }
        if !hasFetchedQuestionnaire {
            hasFetchedQuestionnaire = true
            fetchQuestionnaire()
        }
        updateNavigationButtons()
    }

    func refreshNavigationChrome() {
        hostViewController?.navigationItem.rightBarButtonItem = showsInfoButton
            ? makeInfoBarButtonItem()
            : nil
    }

    // MARK: - User actions

    func openBack() {
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    func showInfo() {
        presentInformationAlert(
            title: AppHelper.getLocalizeString(str: "Information"),
            message: screeningReminder
        )
    }

    func goBackward() {
        let nextPage = pageNumber - 1
        guard nextPage >= 0, nextPage < maxPage else { return }
        pageNumber = nextPage
        updateNavigationButtons()
    }

    func goForward() {
        guard pageNumber < maxPage - 1 else {
            updateNavigationButtons()
            return
        }
        pageNumber += 1
        updateNavigationButtons()
    }

    func completeScreening() {
        let answeredCount = patientAnswers.compactMap { $0 }.count
        if answeredCount == 0 {
            presentInformationAlert(
                title: "",
                message: "Please answer the questions".localized
            )
            return
        }
        submitAnswers()
    }

    func selectOption(at index: Int) {
        guard let screening = selectedScreening,
              let loginResponse = ApplicationSharedInfo.shared.loginResponse,
              questions.indices.contains(pageNumber),
              index >= 0,
              index < questions[pageNumber].answerResponse.count else {
            return
        }

        var indices = selectedAnswerIndices
        indices[pageNumber] = index
        selectedAnswerIndices = indices

        let answerID = "\(patientAnswers[pageNumber]?.answerId ?? 0)"
        patientAnswers[pageNumber] = PatientAnswer(
            from: questions[pageNumber],
            loginDetails: loginResponse,
            screening: screening,
            selectedAnswerIndex: index,
            AnswerID: answerID
        )
    }

    // MARK: - API

    func fetchQuestionnaire() {
        guard let screening = selectedScreening,
              let loginResponse = ApplicationSharedInfo.shared.loginResponse,
              let host = hostViewController,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }

        isLoading = true
        anchorView?.showToastActivity()

        let params: [String: Any] = [
            "screeningId": screening.screeningID,
            "assessmentId": screening.assessmentID,
            "patientLocationId": loginResponse.patientLocationID,
            "patientId": loginResponse.patientID,
            "clientId": loginResponse.clientID,
            "fromDate": "",
            "toDate": "",
        ]

        APIService.screeningQuestionnaireAPICalling(
            host,
            params: params,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleQuestionnaireResponse(response)
            }
        }
    }

    private func handleQuestionnaireResponse(_ response: AnyObject) {
        isLoading = false
        anchorView?.hideToastActivity()

        if let errorMessage = response as? String, errorMessage.hasPrefix("Error:") {
            anchorView?.showToast(message: errorMessage.replacingOccurrences(of: "Error: ", with: ""))
            return
        }

        guard let json = response as? [String: Any],
              let data = try? JSONSerialization.data(withJSONObject: json),
              let decoded = try? JSONDecoder().decode(QuestionnaireResponse.self, from: data) else {
            anchorView?.showToast(message: "An Unknown error occured. Please check with Admin")
            return
        }

        applyQuestionnaire(decoded.questionnaire)
    }

    private func applyQuestionnaire(_ items: [QuestionnaireItem]) {
        questions = items
        pageNumber = 0
        selectedAnswerIndices = Array(repeating: -1, count: items.count)
        patientAnswers = Array(repeating: nil, count: items.count)
        restorePreviouslySelectedAnswers()
        updateNavigationButtons()
    }

    private func restorePreviouslySelectedAnswers() {
        guard let screening = selectedScreening,
              let loginResponse = ApplicationSharedInfo.shared.loginResponse else {
            return
        }

        var indices = selectedAnswerIndices
        var answers = patientAnswers

        for (questionIndex, question) in questions.enumerated() {
            for (optionIndex, option) in question.answerResponse.enumerated() {
                if option.answerId != nil {
                    indices[questionIndex] = optionIndex
                    answers[questionIndex] = PatientAnswer(
                        from: question,
                        loginDetails: loginResponse,
                        screening: screening,
                        selectedAnswerIndex: optionIndex,
                        AnswerID: option.answerId
                    )
                    break
                }
            }
        }

        selectedAnswerIndices = indices
        patientAnswers = answers
    }

    private func submitAnswers() {
        guard let host = hostViewController,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }

        anchorView?.showToastActivity()

        let answersArray: [[String: Any]] = patientAnswers.compactMap { $0 }.map { answer in
            [
                "flag": answer.flag,
                "answerId": answer.answerId,
                "screeningId": answer.screeningId,
                "patientLocationId": answer.patientLocationId,
                "questionnaireId": answer.questionnaireId,
                "optionId": answer.optionId,
                "score": answer.score,
                "clientId": answer.clientId,
                "patientId": answer.patientId,
                "assessmentId": answer.assessmentId,
            ]
        }

        let params: [String: Any] = ["patientAnswers": answersArray]

        APIService.screeningSavePatientAnswersAPICalling(
            host,
            params: params,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleSubmitResponse(response)
            }
        }
    }

    private func handleSubmitResponse(_ response: AnyObject) {
        anchorView?.hideToastActivity()

        if let errorMessage = response as? String, errorMessage.hasPrefix("Error:") {
            anchorView?.showToast(message: errorMessage.replacingOccurrences(of: "Error: ", with: ""))
            return
        }

        guard let json = response as? [String: Any],
              let data = try? JSONSerialization.data(withJSONObject: json),
              let decoded = try? JSONDecoder().decode(ScreeningAnswersSavedResponse.self, from: data) else {
            anchorView?.showToast(message: "An Unknown error occured. Please check with Admin")
            return
        }

        if decoded.statusResponse.responseCode == 200 {
            presentSubmissionSuccessAlert(message: decoded.statusResponse.responseMessage)
        } else {
            presentSubmissionFailureAlert(message: decoded.statusResponse.responseMessage)
        }
    }

    // MARK: - Navigation chrome state

    private func updateNavigationButtons() {
        if maxPage == 0 {
            showsBackwardButton = false
            showsForwardButton = false
            showsCompleteButton = false
            showsInfoButton = true
        } else if pageNumber == 0 {
            showsBackwardButton = false
            showsForwardButton = true
            showsCompleteButton = false
            showsInfoButton = true
        } else if pageNumber == maxPage - 1 {
            showsBackwardButton = true
            showsForwardButton = false
            showsCompleteButton = true
            showsInfoButton = false
        } else {
            showsBackwardButton = true
            showsForwardButton = true
            showsCompleteButton = false
            showsInfoButton = false
        }
        refreshNavigationChrome()
    }

    // MARK: - Alerts

    private func presentInformationAlert(title: String, message: String) {
        guard let host = hostViewController else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok".localized, style: .default))
        host.present(alert, animated: true)
    }

    private func presentSubmissionSuccessAlert(message: String) {
        guard let host = hostViewController else { return }
        let alert = UIAlertController(
            title: AppHelper.getLocalizeString(str: "Screening".localized),
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default) { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.onSubmissionSuccess?(self.selectedScreening)
            }
        })
        host.present(alert, animated: true)
    }

    private func presentSubmissionFailureAlert(message: String) {
        guard let host = hostViewController else { return }
        let alert = UIAlertController(
            title: "Screening".localized,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default) { [weak self] _ in
            self?.hostViewController?.navigationController?.popViewController(animated: true)
        })
        host.present(alert, animated: true)
    }

    private func makeInfoBarButtonItem() -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "InfoIcon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addAction(UIAction { [weak self] _ in
            self?.showInfo()
        }, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 28),
            button.heightAnchor.constraint(equalToConstant: 28),
        ])
        return UIBarButtonItem(customView: button)
    }

    #if DEBUG
    func applyPreviewState(
        questions: [QuestionnaireItem],
        pageNumber: Int = 0,
        selectedIndices: [Int]? = nil
    ) {
        applyQuestionnaire(questions)
        self.pageNumber = pageNumber
        if let selectedIndices {
            selectedAnswerIndices = selectedIndices
        }
        updateNavigationButtons()
    }
    #endif
}
