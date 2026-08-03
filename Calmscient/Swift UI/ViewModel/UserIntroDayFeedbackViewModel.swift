//
//  UserIntroDayFeedbackViewModel.swift
//  Calmscient
//
//  Post-login day feedback — mirrors `UserIntroDayFeedbackViewController` (API + save + skip).
//
//  Vivek
//  14 May 2026
//
import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class UserIntroDayFeedbackViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    /// When non-nil, inline greeting is hidden and the navigation item title is set (dashboard push).
    var dashboardNavigationTitle: String?

    var hideSkipButton: Bool = false

    private let startupDayData: UserStartupScreenDayData?
    private let sleepValueStrings = DayFeedbackLayout.sleepHourValues
    private let spendKeys = DayFeedbackLayout.spendOptionKeys

    private var plId: Int { ApplicationSharedInfo.shared.loginResponse?.patientLocationID ?? 0 }
    private var clientId: Int { ApplicationSharedInfo.shared.loginResponse?.clientID ?? 0 }
    private var patientId: Int { ApplicationSharedInfo.shared.loginResponse?.patientID ?? 0 }

    let rows: [DayFeedbackRow]

    @Published var greetingTitle: String = ""
    @Published var useLargeInlineGreeting: Bool = true

    @Published var moodSelectedIndex: Int?
    @Published var moodApiBaselineIndex: Int?
    @Published var focusSelectedIndex: Int?
    @Published var focusApiBaselineIndex: Int?

    @Published var sleepCollectionIndex: Int?
    @Published var sleepSummaryText: String = ""

    @Published var spendSelectedIndices: Set<Int> = []

    /// Mirrors UIKit values: "1" = yes, "0" = no, "2" = not yet.
    @Published var medicineSelectionValue: String?

    @Published var journalText: String = ""
    /// Server-prefilled journal (used for the same mood-change warning as UIKit).
    @Published private(set) var serverJournalPrefetch: String?
    private var isJournalClearedByUser = false

    @Published private(set) var isFetching: Bool = false

    private var currentTimeString: String?
    private var medicineFlagString: String?

    private let mandatoryAlertMessage: String

    init(
        startupDayData: UserStartupScreenDayData? = nil,
        dashboardNavigationTitle: String? = nil,
        hideSkipButton: Bool = false
    ) {
        self.startupDayData = startupDayData ?? UserStartupScreenDayData.getStartUpScreenData()
        self.rows = DayFeedbackRow.rows(for: self.startupDayData?.dayTimeValue)
        self.dashboardNavigationTitle = dashboardNavigationTitle
        self.hideSkipButton = hideSkipButton
        self.mandatoryAlertMessage = AppHelper.getLocalizeString(str: "Please fill all mandatory fields.")

        let titleString = UserDefaults.standard.string(forKey: "titleString") ?? "V"
        greetingTitle = Self.buildGreeting(dayTime: self.startupDayData?.dayTimeValue, titleString: titleString)
    }

    func configureNavigationChrome() {
        if let dashboardNavigationTitle, !dashboardNavigationTitle.isEmpty {
            useLargeInlineGreeting = false
            hostViewController?.navigationItem.title = greetingTitle
        } else {
            useLargeInlineGreeting = true
        }
    }

    func onAppearRefreshIfNeeded() {
        configureNavigationChrome()
        currentTimeString = DayFeedbackSessionLogic.apiTimestamp()

        if TokenManager.shared.isTokenExpired() {
            TokenManager.shared.refreshAccessToken(from: hostViewController) { [weak self] success in
                Task { @MainActor in
                    guard let self else { return }
                    if success {
                        self.fetchMoodScreenData()
                    } else {
                        UserDefaults.standard.set(0, forKey: "rememberMe")
                        UserDefaultsHelper.clearLoginDetailsFromUserDefaults()
                        ApplicationSharedInfo.shared.loginResponse = nil
                        ApplicationSharedInfo.shared.tokenResponse = nil
                        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                            let navController = LoginHostingController.loginNavigationRoot()
                            sceneDelegate.changeRootViewController(to: navController)
                        }
                    }
                }
            }
        } else {
            fetchMoodScreenData()
        }
    }

    func setMoodIndex(_ index: Int?) {
        guard let dayData = startupDayData else { return }
        moodSelectedIndex = index
        if let index, index >= 0 {
            if let options = dayData.moodData?.options, index < options.count {
                dayData.moodAnswer = options[index].optionTypeID
            } else {
                dayData.moodAnswer = index + 1
            }
        } else {
            dayData.moodAnswer = nil
        }

        if index != moodApiBaselineIndex, shouldPromptJournalClearOnMoodChange() {
            presentJournalClearPrompt(forFocus: false)
        }
    }

    func setFocusIndex(_ index: Int?) {
        guard let dayData = startupDayData else { return }
        focusSelectedIndex = index
        if let index, index >= 0 {
            if let options = dayData.focusData?.options, index < options.count {
                dayData.focusAnswer = options[index].optionTypeID
            } else {
                dayData.focusAnswer = index + 1
            }
        } else {
            dayData.focusAnswer = nil
        }

        if index != focusApiBaselineIndex, shouldPromptJournalClearOnMoodChange() {
            presentJournalClearPrompt(forFocus: true)
        }
    }

    func toggleSpendIndex(_ index: Int) {
        guard let dayData = startupDayData else { return }
        if spendSelectedIndices.contains(index) {
            spendSelectedIndices.remove(index)
        } else {
            spendSelectedIndices.insert(index)
        }
        let answers = spendSelectedIndices.sorted().map { String($0 + 1) }
        dayData.timeSpendAnswer = answers.isEmpty ? nil : answers
    }

    func setSleepIndex(_ index: Int) {
        guard let dayData = startupDayData else { return }
        sleepCollectionIndex = index
        dayData.sleepAnswer = index
        sleepSummaryText = Self.sleepSummary(for: index)
    }

    func setMedicineSelection(_ value: String) {
        guard let dayData = startupDayData else { return }
        medicineSelectionValue = value
        dayData.medicineAnswer = value
    }

    func journalChanged(_ text: String) {
        guard let dayData = startupDayData else { return }
        let clipped = String(Self.sanitizeJournalInput(text).prefix(2000))
        journalText = clipped
        dayData.journalAnswer = journalText
    }

    func save() {
        anchorView?.endEditing(true)
        guard let dayData = startupDayData, let dayTime = dayData.dayTimeValue else { return }

        switch dayTime {
        case .Morning, .Afternoon:
            guard let moodId = dayData.moodAnswer,
                  let focusId = dayData.focusAnswer,
                  let sleepIdx = sleepCollectionIndex,
                  sleepIdx >= 0, sleepIdx <= 8
            else {
                presentMandatoryAlert()
                return
            }
            let updatedSleepHours = sleepIdx + 1
            guard updatedSleepHours > 0, updatedSleepHours <= sleepValueStrings.count else {
                presentMandatoryAlert()
                return
            }
            let sleepAns = Int(sleepValueStrings[updatedSleepHours - 1]) ?? 0
            guard !journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                presentMandatoryAlert()
                return
            }

            let answers = PatientLog()
            let medicineFlag = dayData.medicineAnswer
            medicineFlagString = medicineFlag
            answers.moodId = moodId
            answers.medsTrackingId = focusId
            answers.sleepHours = sleepAns
            answers.mentalClarityId = medicineFlagCode(from: medicineFlag)
            answers.journal = journalText
            answers.activityDate = currentTimeString ?? DayFeedbackSessionLogic.apiTimestamp()
            applyQuestionPayload(from: dayData, to: answers)
            sendSave(answers: answers)

        case .Evening:
            guard let moodId = dayData.moodAnswer,
                  let focusId = dayData.focusAnswer,
                  let sleepIdx = sleepCollectionIndex,
                  sleepIdx >= 0, sleepIdx <= 8,
                  !journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else {
                presentMandatoryAlert()
                return
            }
            
            let updatedSleepHours = sleepIdx + 1
            guard updatedSleepHours > 0, updatedSleepHours <= sleepValueStrings.count else {
                presentMandatoryAlert()
                return
            }
            
            let sleepAns = Int(sleepValueStrings[updatedSleepHours - 1]) ?? 0
            let medicineFlag = dayData.medicineAnswer
            medicineFlagString = medicineFlag
            let answers = PatientLog()
            answers.moodId = moodId
            answers.medsTrackingId = focusId
            answers.mentalClarityId = medicineFlagCode(from: medicineFlag)
            answers.sleepHours = sleepAns
            answers.journal = journalText
            answers.activityDate = currentTimeString ?? DayFeedbackSessionLogic.apiTimestamp()
            applyQuestionPayload(from: dayData, to: answers)
            sendSave(answers: answers)
        }
    }

    /// Read-only access for question copy (same JSON as UIKit).
    var templateData: UserStartupScreenDayData? { startupDayData }

    func skip() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
              let window = sceneDelegate.window else { return }
        let homeController = UIStoryboard(name: "AppTabBar", bundle: nil)
            .instantiateViewController(withIdentifier: "AppMainTabViewController") as! AppMainTabViewController
        homeController.isInitalView = false
        window.rootViewController = homeController
        window.makeKeyAndVisible()
        DayFeedbackEveningReminderScheduler.refreshSchedulingIfNeeded()
    }

    private var anchorView: UIView? { hostViewController?.view }

    private static func buildGreeting(dayTime: DayTimeValue?, titleString: String) -> String {
        guard let dayTime else { return "\(titleString)" }
        switch dayTime {
        case .Morning, .Afternoon:
            return "\("Hello".localized) \(titleString)!"
        case .Evening:
            return "\("Good evening".localized) \(titleString)!"
        }
    }

    private static func sleepSummary(for index: Int) -> String {
        switch index {
        case 0:
            return "sleep_summary_less_than_four".localized
        case 8:
            return "sleep_summary_more_than_ten".localized
        case 1 ..< 8:
            let hourLabel = "\(index + 3)"
            return String(format: "sleep_summary_hours_format".localized, hourLabel)
        default:
            return ""
        }
    }

    private static func sleepHourDigitLabel(collectionIndex: Int) -> String {
        guard (1 ... 7).contains(collectionIndex) else { return "" }
        return "\(collectionIndex + 3)"
    }

    static func sleepCircleLabel(at index: Int) -> String {
        switch index {
        case 0: return "sleep_circle_less".localized
        case 8: return "sleep_circle_more".localized
        default: return sleepHourDigitLabel(collectionIndex: index)
        }
    }

    private func fetchMoodScreenData() {
        guard let time = currentTimeString else { return }
        let params = DayFeedbackSessionLogic.moodFetchAPIParameters(
            patientLocationId: plId,
            clientId: clientId,
            patientId: patientId,
            time: time
        )
        isFetching = true
        anchorView?.showToastActivity()
        guard let apiHost = hostViewController else {
            isFetching = false
            anchorView?.hideToastActivity()
            return
        }
        APIService.FetchMoodScreenDataAPICalling(
            apiHost,
            params: params,
            method: "POST",
            accessToken: ApplicationSharedInfo.shared.tokenResponse?.accessToken ?? "",
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.applyFetchResponse(response)
                self?.anchorView?.hideToastActivity()
                self?.isFetching = false
            }
        }
    }

    private func applyFetchResponse(_ response: AnyObject) {
        if response is String {
            let alertController = UIAlertController(
                title: "Error".localized,
                message: "Failed to fetch data. Would you like to retry?".localized,
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "Retry".localized, style: .default) { [weak self] _ in
                self?.onAppearRefreshIfNeeded()
            })
            alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))
            hostViewController?.present(alertController, animated: true)
            return
        }

        guard let responseDict = response as? [String: Any] else {
            print("Unsupported response type:", type(of: response))
            return
        }

        guard let dayData = startupDayData else { return }

        do {
            let responseData = try JSONSerialization.data(withJSONObject: responseDict, options: [])
            let decoded = try JSONDecoder().decode(UserStartupScreenDayData.self, from: responseData)
            if let answersList = decoded.startupAnswersDtoList, !answersList.isEmpty {
                for answer in answersList {
                    switch answer.activitySection {
                    case "Mood Monitor":
                        let raw = Int(answer.activityResponse?.first ?? "-1") ?? 0
                        let idx = raw - 1
                        if (0 ..< 5).contains(idx) {
                            moodSelectedIndex = idx
                            moodApiBaselineIndex = idx
                            if let options = dayData.moodData?.options, idx < options.count {
                                dayData.moodAnswer = options[idx].optionTypeID
                            } else {
                                dayData.moodAnswer = raw
                            }
                        }
                    case "Focus":
                        let raw = Int(answer.activityResponse?.first ?? "-1") ?? 0
                        let idx = raw - 1
                        if (0 ..< 5).contains(idx) {
                            focusSelectedIndex = idx
                            focusApiBaselineIndex = idx
                            if let options = dayData.focusData?.options, idx < options.count {
                                dayData.focusAnswer = options[idx].optionTypeID
                            } else {
                                dayData.focusAnswer = raw
                            }
                        }
                    case "Sleep Hours":
                        if let first = answer.activityResponse?.first,
                           let arrayIndex = sleepValueStrings.firstIndex(of: first) {
                            sleepCollectionIndex = arrayIndex
                            dayData.sleepAnswer = arrayIndex
                            sleepSummaryText = Self.sleepSummary(for: arrayIndex)
                        } else {
                            sleepCollectionIndex = nil
                            sleepSummaryText = ""
                        }
                    case "Medication":
                        if let first = answer.activityResponse?.first {
                            let normalized: String
                            switch first {
                            case "1", "Yes":
                                normalized = "1"
                            case "0", "No":
                                normalized = "0"
                            case "2", "Not yet", "NotYet":
                                normalized = "2"
                            default:
                                normalized = "0"
                            }
                            medicineSelectionValue = normalized
                            dayData.medicineAnswer = normalized
                        }
                    case "Journal":
                        if let j = answer.activityResponse?.first, !j.isEmpty {
                            serverJournalPrefetch = j
                            if !isJournalClearedByUser {
                                journalText = j
                                dayData.journalAnswer = j
                            }
                        }
                    case "SpendTime":
                        let fetched: [String] = answer.activityResponse?.compactMap { String($0) } ?? []
                        let oneBased = fetched.compactMap { spendKeys.firstIndex(of: $0).map { $0 + 1 } }
                        spendSelectedIndices = Set(oneBased.map { $0 - 1 })
                        dayData.timeSpendAnswer = oneBased.map { String($0) }
                    default:
                        break
                    }
                }
            }
        } catch {
            print("Failed to decode UserStartupScreenDayData:", error)
        }
    }

    private func sendSave(answers: PatientLog) {
        anchorView?.showToastActivity()
        APIService.savePatientStartupScreenAPICalling(answers: answers) { [weak self] (response: ResponseDetails?, failureResponse: FailureResponse?, error: Error?) in
            Task { @MainActor in
                guard let self else { return }
                self.anchorView?.hideToastActivity()
                if let err = error {
                    self.anchorView?.showToast(message: err.localizedDescription)
                } else if let response = response {
                    if response.responseCode == 200 {
                        
                        print("viv th response of user intro is \(response.responseMessage)")
                        
                        DayFeedbackSessionLogic.recordLastSessionPeriod()
                        if self.startupDayData?.dayTimeValue == .Evening {
                            DayFeedbackEveningReminderScheduler.cancelEveningReminder()
                        }
                        self.hostViewController?.showSuccessAlert(
                            successContent: response.responseMessage,
                            okButtonAction: { [weak self] in
                                guard let self else { return }
                                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
                                   let window = sceneDelegate.window {
                                    let homeController = UIStoryboard(name: "AppTabBar", bundle: nil)
                                        .instantiateViewController(withIdentifier: "AppMainTabViewController") as! AppMainTabViewController
                                    homeController.isInitalView = ((self.medicineFlagString ?? "0") == "0")
                                    window.rootViewController = homeController
                                    window.makeKeyAndVisible()
                                }
                                DayFeedbackEveningReminderScheduler.refreshSchedulingIfNeeded()
                            }
                        )
                    } else {
                        self.anchorView?.showToast(message: response.responseMessage)
                    }
                } else if let failureResponse = failureResponse {
                    self.anchorView?.showToast(message: failureResponse.statusResponse.responseMessage)
                }
            }
        }
    }

    private func presentMandatoryAlert() {
        hostViewController?.showGeneralAlert(
            image: UIImage(named: "InfoIcon"),
            imageSize: CGSize(width: 60, height: 60),
            title: mandatoryAlertMessage,
            okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
            okAction: {},
            dismissAction: {}
        )
    }

    private func shouldPromptJournalClearOnMoodChange() -> Bool {
        if isJournalClearedByUser { return false }
        if let s = serverJournalPrefetch, !s.isEmpty { return true }
        return false
    }

    private func presentJournalClearPrompt(forFocus: Bool) {
        hostViewController?.showGeneralAlertYesNo(
            image: UIImage(named: "question2"),
            imageSize: CGSize(width: 60, height: 60),
            title: "",
            subTitle: AppHelper.getLocalizeString(str: forFocus ? "Would you like to update your focus?" : "Would you like to update your mood?"),
            okButtonTitle: AppHelper.getLocalizeString(str: "YES"),
            cancelButtonTitle: AppHelper.getLocalizeString(str: "NO"),
            okAction: { [weak self] in
                Task { @MainActor in
                    guard let self, let dayData = self.startupDayData else { return }
                    self.serverJournalPrefetch = nil
                    self.isJournalClearedByUser = true
                    self.journalText = ""
                    dayData.journalAnswer = ""
                }
            },
            cancelAction: {},
            subtitleFontSize: 14
        )
    }

    private static func sanitizeJournalInput(_ text: String) -> String {
        text.filter { !["<", ">", "/"].contains($0) }
    }

    private func medicineFlagCode(from value: String?) -> Int {
        switch value {
        case "1", "Yes":
            return 1
        case "0", "No":
            return 0
        case "2", "Not yet", "NotYet":
            return 2
        default:
            return 0
        }
    }

    private func applyQuestionPayload(from dayData: UserStartupScreenDayData, to answers: PatientLog) {
        answers.moodQuestion = dayData.moodData?.moodQuestion ?? ""
        answers.medsTrackingQuestion = dayData.focusData?.focusQuestion ?? "How is your focus/mental clarity?"
        answers.sleepQuestion = dayData.sleepData?.sleepQuestion ?? ""
        answers.mentalClarityQuestion = dayData.medicineData?.medicineQuestion ?? ""
        answers.spendQuestion = dayData.timeSpendData?.timeSpendQuestion ?? ""
        answers.wish = dayData.wish
    }
}
