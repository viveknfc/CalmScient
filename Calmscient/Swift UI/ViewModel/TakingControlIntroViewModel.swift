//
//  TakingControlIntroViewModel.swift
//  Calmscient
//
//  State, API, and navigation for the Taking Control CAGE-AID intro (parity with `VTakingControlIntroVC`).
//
//  Vivek
//  19 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class TakingControlIntroViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var screenTitle: String = ""
    @Published private(set) var introAttributedText: AttributedString = AttributedString()
    @Published private(set) var questionRows: [TakingControlIntroQuestionRowPresentation] = []
    @Published private(set) var yesCount: Int = 0
    @Published private(set) var yourPointsTitle: String = ""
    @Published private(set) var interpretationText: String = ""
    @Published private(set) var yesButtonTitle: String = ""
    @Published private(set) var noButtonTitle: String = ""
    @Published private(set) var submitButtonTitle: String = ""
    @Published private(set) var isLoading = false

    private var questionnaireArray: [Question] = []
    private var summaryArray: [TakingFirstQueSummary] = []
    private var assessmentId = 0
    private var auditScreeningData: [Screening] = []
    private var dast10ScreeningData: [Screening] = []

    private var hasStartedLoad = false
    private var anchorView: UIView? { hostViewController?.view }

    private let headingFont = LoginDesignSystem.Typography.lexendRegular(size: 14)
    private let bodyFont = LoginDesignSystem.Typography.lexendLight(size: 14)

    init() {
        reloadLocalizedStrings()
    }

    func reloadLocalizedStrings() {
        screenTitle = "Taking control introduction".localized
        yourPointsTitle = "Your points".localized
        interpretationText = "Taking control CAGE interpretation".localized
        yesButtonTitle = "Yes".localized
        noButtonTitle = "No".localized
        submitButtonTitle = "Submit".localized

        let fullText = "Taking control Intro".localized
        introAttributedText = TakingControlIntroPresentation.makeIntroAttributedText(
            fullText: fullText,
            headingFont: headingFont,
            bodyFont: bodyFont
        )
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
        guard !hasStartedLoad else { return }
        hasStartedLoad = true
        fetchAssessmentId()
    }

    func openBack() {
        guard let host = hostViewController else { return }
        TakingControlIndexNavigation.push(from: host, initialSegment: 0)
    }

    func selectAnswer(_ answer: TakingControlIntroBinaryAnswer, forQuestionAt index: Int) {
        guard summaryArray.indices.contains(index),
              questionnaireArray.indices.contains(index) else { return }

        let question = questionnaireArray[index]
        let optionIndex = answer == .yes ? 1 : 0
        guard question.answerResponse.indices.contains(optionIndex) else { return }

        let selectedOption = question.answerResponse[optionIndex]
        var summary = summaryArray[index]
        summary.selectedanswerId = selectedOption.answerId
        summary.selectedScore = selectedOption.optionScoreInt
        summary.selectedoptionId = selectedOption.optionLabelId
        summary.selectedAnswerLabel = selectedOption.optionLabel
        summaryArray[index] = summary

        var rows = questionRows
        if rows.indices.contains(index) {
            rows[index].selectedAnswer = answer
            questionRows = rows
        }
        updateYesCount()
    }

    func submitTapped() {
        let unanswered = summaryArray.indices.first { index in
            guard questionRows.indices.contains(index) else { return true }
            return questionRows[index].selectedAnswer == nil
        }

        if unanswered != nil {
            hostViewController?.showGeneralAlert(
                image: UIImage(named: "InfoIcon"),
                imageSize: CGSize(width: 60, height: 60),
                title: "Please answer all questions".localized,
                okButtonTitle: "Ok".localized,
                okAction: {},
                showDismissButton: false
            )
            return
        }

        submitAnswers()
    }

    // MARK: - API

    private func fetchAssessmentId() {
        guard let loginResponse = ApplicationSharedInfo.shared.loginResponse,
              let host = hostViewController,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }

        isLoading = true
        anchorView?.showToastActivity()

        let params: [String: Any] = [
            "patientId": loginResponse.patientID,
            "patientLocationId": loginResponse.patientLocationID,
            "clientId": loginResponse.clientID,
        ]

        APIService.screeningListAssessmentrIdAPICalling(
            host,
            params: params,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleAssessmentIdResponse(response)
            }
        }
    }

    private func handleAssessmentIdResponse(_ response: AnyObject) {
        if let responseString = response as? String, responseString.hasPrefix("Error:") {
            isLoading = false
            anchorView?.hideToastActivity()
            anchorView?.showToast(message: responseString.replacingOccurrences(of: "Error: ", with: ""))
            return
        }

        guard let json = response as? [String: Any],
              let data = try? JSONSerialization.data(withJSONObject: json),
              let decoded = try? JSONDecoder().decode(ScreeningResponse.self, from: data) else {
            isLoading = false
            anchorView?.hideToastActivity()
            return
        }

        let allScreenings = decoded.screeningList
        auditScreeningData = allScreenings.filter { $0.screeningType.uppercased() == "AUDIT" }
        dast10ScreeningData = allScreenings.filter { $0.screeningType.uppercased() == "DAST-10" }

        if let cageAssessment = allScreenings.first(where: { $0.screeningType == "CAGE-AID" }) {
            assessmentId = cageAssessment.assessmentID
            fetchQuestionnaire()
        } else {
            isLoading = false
            anchorView?.hideToastActivity()
        }
    }

    private func fetchQuestionnaire() {
        guard let loginResponse = ApplicationSharedInfo.shared.loginResponse,
              let host = hostViewController,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            isLoading = false
            anchorView?.hideToastActivity()
            return
        }

        let params: [String: Any] = [
            "assessmentId": assessmentId,
            "screeningId": 5,
            "patientId": loginResponse.patientID,
            "patientLocationId": loginResponse.patientLocationID,
            "clientId": loginResponse.clientID,
            "fromDate": "",
            "toDate": "",
        ]

        APIService.takingccontrolIntrofirstscreenDataAPICalling(
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

        if let responseString = response as? String, responseString.hasPrefix("Error:") {
            anchorView?.showToast(message: responseString.replacingOccurrences(of: "Error: ", with: ""))
            return
        }

        guard let json = response as? [String: Any],
              let data = try? JSONSerialization.data(withJSONObject: json),
              let decoded = try? JSONDecoder().decode(TakingIntrofirstScreenQuestions.self, from: data) else {
            return
        }

        questionnaireArray = decoded.questionnaire
        summaryArray = decoded.questionnaire.map {
            TakingFirstQueSummary(
                questionId: $0.questionId,
                questionName: $0.questionName,
                optionTypeId: $0.optionTypeId,
                selectedanswerId: nil,
                selectedScore: nil,
                selectedoptionId: nil,
                selectedAnswerLabel: ""
            )
        }
        questionRows = decoded.questionnaire.enumerated().map { index, question in
            TakingControlIntroQuestionRowPresentation(
                id: index,
                questionText: question.questionName,
                selectedAnswer: nil
            )
        }
        updateYesCount()
    }

    private func submitAnswers() {
        guard let loginResponse = ApplicationSharedInfo.shared.loginResponse,
              let host = hostViewController,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }

        anchorView?.showToastActivity()

        let answersArrayParam: [[String: Any]] = summaryArray.map { question in
            [
                "flag": "I",
                "answerId": question.selectedanswerId ?? 0,
                "optionId": question.selectedoptionId ?? 0,
                "score": question.selectedScore ?? 0,
                "questionnaireId": question.questionId,
                "screeningId": 5,
                "patientLocationId": loginResponse.patientLocationID,
                "clientId": loginResponse.clientID,
                "patientId": loginResponse.patientID,
                "assessmentId": assessmentId,
            ]
        }

        let params: [String: Any] = ["patientAnswers": answersArrayParam]

        APIService.takingccontrolIntrofirstscreenAnswerAPICalling(
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

        if let responseString = response as? String, responseString.hasPrefix("Error:") {
            anchorView?.showToast(message: responseString.replacingOccurrences(of: "Error: ", with: ""))
            return
        }

        guard let json = response as? [String: Any],
              let statusResponse = json["statusResponse"] as? [String: Any],
              let responseMessage = statusResponse["responseMessage"] as? String else {
            return
        }

        hostViewController?.showSuccessAlert(successContent: responseMessage, centreImage: nil) { [weak self] in
            self?.pushIntroSecondPage()
        }
    }

    private func pushIntroSecondPage() {
        guard let nav = hostViewController?.navigationController else { return }
        let secondPage = TakingControlIntroSecondHostingController()
        secondPage.configure(auditData: auditScreeningData, dastData: dast10ScreeningData)
        nav.pushViewController(secondPage, animated: true)
    }

    private func updateYesCount() {
        yesCount = questionRows.filter { $0.selectedAnswer == .yes }.count
    }

    #if DEBUG
    func applyPreviewState(
        rows: [TakingControlIntroQuestionRowPresentation],
        yesCount: Int? = nil
    ) {
        reloadLocalizedStrings()
        questionRows = rows
        self.yesCount = yesCount ?? rows.filter { $0.selectedAnswer == .yes }.count
    }
    #endif
}

// MARK: - Navigation

@available(iOS 16.0, *)
enum TakingControlIntroNavigation {

    static func push(from host: UIViewController, animated: Bool = true) {
        guard let nav = host.navigationController else { return }

        let backItem = UIBarButtonItem()
        backItem.title = ""
        host.navigationItem.backBarButtonItem = backItem

        let introScreen = TakingControlIntroHostingController()
        nav.pushViewController(introScreen, animated: animated)
    }
}
