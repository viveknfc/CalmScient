//
//  JournalEntryViewModel.swift
//  Calmscient
//
//  State, filtering, calendar filter, and journal APIs (parity with `JournalEntryViewController`).
//
//  Vivek
//  18 May 2026
//

import Foundation
import Network
import SwiftUI
import UIKit

@available(iOS 16.0, *)
enum JournalEntrySegment: Int, CaseIterable, Identifiable {
    case questionnaire = 1
    case diary = 2
    case discovery = 3

    var id: Int { rawValue }
}

@available(iOS 16.0, *)
@MainActor
final class JournalEntryViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    // MARK: - SwiftUI navigation
    //
    // Set by `HomeTabView` when this screen is shown inside the Home `NavigationStack`.
    // While nil, every call below falls through to the existing UIKit push/pop, which is
    // what the still-UIKit Discovery tab uses when it pushes into these screens.
    var onOpenRoute: ((HomeRoute) -> Void)?
    var onClose: (() -> Void)?
    var onCloseToRoot: (() -> Void)?

    @Published var searchText: String = ""
    @Published var selectedSegment: JournalEntrySegment = .questionnaire
    @Published private(set) var quizRows: [JournalQuizRowPresentation] = []
    @Published private(set) var dailySections: [JournalDailySectionPresentation] = []
    @Published private(set) var discoveryRows: [JournalDiscoveryRowPresentation] = []
    @Published private(set) var isLoading = false
    @Published var expandedRowIDs: Set<String> = []
    @Published var isAddJournalPresented = false
    @Published private(set) var isOffline = false

    @Published private(set) var navigationChromeTitle: String = ""

    private var quizData: [[String: Any]] = []
    private var dailyData: [[String: Any]] = []
    private var discoverData: [[String: Any]] = []

    private let datePickerPresenter = BottomSheetDatePickerPresenter()
    private var pathMonitor: NWPathMonitor?
    private let pathMonitorQueue = DispatchQueue(label: "journal.entry.path.monitor")

    /// Falls back to the key window so this screen still shows toasts when it is
    /// presented without a `hostViewController` (SwiftUI-navigated Home tab).
    private var anchorView: UIView? { Toast.resolvedAnchor(hostViewController?.view) }

    func onHostViewDidLoad() {
        reloadLocalizedChrome()
        loadJournalData(fromDate: "")
    }

    /// Seeds the localized chrome up front so the navigation title is correct on the
    /// very first SwiftUI body evaluation (the UIKit host used to set it in `viewWillAppear`).
    init() {
        reloadLocalizedChrome()
    }

    func onHostWillAppear() {
        startPathMonitor()
        // Only poke the UIKit chrome on the legacy path. Inside the SwiftUI Home stack
        // the navigation bar and tab bar belong to SwiftUI, and reaching past it leaves
        // the two out of sync.
        if onClose == nil {
            navigationController?.setNavigationBarHidden(false, animated: true)
            tabBarController?.tabBar.isHidden = false
            tabBarController?.tabBar.selectedItem?.title = "main_tab_bar_home".localized
        }
        reloadLocalizedChrome()
    }

    func onHostWillDisappear() {
        stopPathMonitor()
    }

    func reloadLocalizedChrome() {
        navigationChromeTitle = "nav_title_journal_entry".localized
    }

    private var navigationController: UINavigationController? {
        hostViewController?.navigationController
    }

    private var tabBarController: UITabBarController? {
        hostViewController?.tabBarController
    }

    // MARK: - Network reachability

    private func startPathMonitor() {
        guard pathMonitor == nil else { return }
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isOffline = path.status != .satisfied
            }
        }
        monitor.start(queue: pathMonitorQueue)
        pathMonitor = monitor
        isOffline = monitor.currentPath.status != .satisfied
    }

    private func stopPathMonitor() {
        pathMonitor?.cancel()
        pathMonitor = nil
    }

    // MARK: - Segments & search

    func onSegmentFilterChanged() {
        searchText = ""
        expandedRowIDs.removeAll()
        applySearchAndRebuildLists()
    }

    func updateSearchFromUI(_ text: String) {
        searchText = text
        applySearchAndRebuildLists()
    }

    func toggleExpanded(rowID: String) {
        if expandedRowIDs.contains(rowID) {
            expandedRowIDs.remove(rowID)
        } else {
            expandedRowIDs.insert(rowID)
        }
    }

    // MARK: - Calendar

    func presentCalendarPicker() {
        guard let host = hostViewController else { return }
        datePickerPresenter.present(
            from: host,
            configuration: BottomSheetDatePickerConfiguration(
                pickerMode: .date,
                maximumDate: Date(),
                showsDimmingOverlay: true
            ),
            onDateSelected: { [weak self] date, _ in
                guard let self else { return }
                let formatted = Self.formatCalendarRequestDate(date)
                self.loadJournalData(fromDate: formatted)
            },
            onDismiss: nil
        )
    }

    private static func formatCalendarRequestDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let resetDate = calendar.startOfDay(for: date)
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy"
        df.locale = Locale(identifier: "en_US")
        df.timeZone = TimeZone.current
        return df.string(from: resetDate)
    }

    // MARK: - Navigation

    func openBack() {
        if let onClose {
            onClose()
            return
        }
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    func openNeedToTalk() {
        if let onOpenRoute {
            onOpenRoute(.needToTalk)
            return
        }
        guard let host = hostViewController else { return }
        NeedToTalkNavigation.push(from: host)
    }

    // MARK: - API — fetch combined journal payload

    func loadJournalData(fromDate: String) {
        guard let login = ApplicationSharedInfo.shared.loginResponse,
              let host = hostViewController,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }

        isLoading = true
        anchorView?.showToastActivity()

        let params: [String: Any] = [
            "patientLocationId": login.patientLocationID,
            "clientId": login.clientID,
            "patientId": login.patientID,
            "fromDate": fromDate,
            "entry": "",
        ]

        APIService.JournalDataAPICalling(
            host,
            params: params,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleJournalFetchResponse(response)
            }
        }
    }

    private func handleJournalFetchResponse(_ response: AnyObject) {
        isLoading = false
        anchorView?.hideToastActivity()

        if let message = response as? String, message.hasPrefix("Error:") {
            anchorView?.showToast(message: message.replacingOccurrences(of: "Error: ", with: ""))
            return
        }

        guard let dict = response as? [String: Any] else {
            return
        }

        if let quiz = dict["quiz"] as? [[String: Any]] {
            quizData = quiz
        }
        if let daily = dict["dailyJournal"] as? [[String: Any]] {
            dailyData = daily
        }
        if let discovery = dict["discoveryExercises"] as? [[String: Any]] {
            discoverData = discovery
        }

        applySearchAndRebuildLists()
    }

    // MARK: - API — add daily journal

    func submitNewJournalEntry(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            hostViewController?.showGeneralAlert(
                image: UIImage(named: "InfoIcon"),
                imageSize: CGSize(width: 40, height: 40),
                title: "Please enter journal details".localized,
                okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                okAction: {},
                dismissAction: {}
            )
            return
        }

        guard let login = ApplicationSharedInfo.shared.loginResponse,
              let host = hostViewController,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }

        let df = DateFormatter()
        df.timeZone = TimeZone.current
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let createdAt = df.string(from: Date())

        let params: [String: Any] = [
            "patientId": login.patientID,
            "entry": trimmed,
            "plId": login.patientLocationID,
            "clientId": login.clientID,
            "entryType": "daily_journal",
            "createdAt": createdAt,
        ]

        anchorView?.showToastActivity()

        APIService.AddJournalAPICalling(
            host,
            params: params,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleAddJournalResponse(response)
            }
        }
    }

    private func handleAddJournalResponse(_ response: AnyObject) {
        anchorView?.hideToastActivity()

        if let message = response as? String, message.hasPrefix("Error:") {
            anchorView?.showToast(message: message.replacingOccurrences(of: "Error: ", with: ""))
            return
        }

        guard let dict = response as? [String: Any],
              let responseMessage = dict["responseMessage"] as? String else {
            return
        }

        isAddJournalPresented = false

        hostViewController?.showSuccessAlert(successContent: responseMessage, okButtonAction: { [weak self] in
            self?.refreshDailyJournalAfterAdd()
        })
    }

    private func refreshDailyJournalAfterAdd() {
        guard let login = ApplicationSharedInfo.shared.loginResponse,
              let host = hostViewController,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }

        anchorView?.showToastActivity()

        let params: [String: Any] = [
            "patientId": login.patientID,
            "entry": "",
            "patientLocationId": login.patientLocationID,
            "clientId": login.clientID,
            "fromDate": "",
        ]

        APIService.JournalDataAPICalling(
            host,
            params: params,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleRefreshDailyOnly(response)
            }
        }
    }

    private func handleRefreshDailyOnly(_ response: AnyObject) {
        anchorView?.hideToastActivity()

        if let message = response as? String, message.hasPrefix("Error:") {
            anchorView?.showToast(message: message.replacingOccurrences(of: "Error: ", with: ""))
            return
        }

        guard let dict = response as? [String: Any],
              let daily = dict["dailyJournal"] as? [[String: Any]] else {
            return
        }

        dailyData = daily.sorted { d1, d2 in
            let s1 = d1["sno"] as? Int ?? 0
            let s2 = d2["sno"] as? Int ?? 0
            return s1 < s2
        }

        applySearchAndRebuildLists()
    }

    // MARK: - Filtering / grouping

    private func applySearchAndRebuildLists() {
        rebuildQuizRows()
        rebuildDailySections()
        rebuildDiscoveryRows()
    }

    private func rebuildQuizRows() {
        var rows = quizData
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !q.isEmpty {
            rows = rows.filter { event in
                guard let title = event["title"] as? String else { return false }
                return title.lowercased().contains(q.lowercased())
            }
        }
        rows.sort { a, b in
            let d1 = Self.quizCompletionDate(from: a["completionDateTime"] as? String)
            let d2 = Self.quizCompletionDate(from: b["completionDateTime"] as? String)
            switch (d1, d2) {
            case let (date1?, date2?):
                return date1 > date2
            case (_?, nil):
                return true
            case (nil, _?):
                return false
            default:
                let t1 = a["title"] as? String ?? ""
                let t2 = b["title"] as? String ?? ""
                return t1 < t2
            }
        }

        quizRows = rows.compactMap { event in
            guard let title = event["title"] as? String else { return nil }
            let completion = event["completionDateTime"] as? String ?? ""
            let score = event["score"] as? Int ?? 0
            let total = event["totalScore"] as? Int ?? 0
            let id = "\(title)|\(completion)|\(score)"
            let dateText = Self.formatQuizDateTime(completion) ?? completion
            return JournalQuizRowPresentation(
                id: id,
                sectionTitle: title.uppercased(),
                dateTimeText: dateText,
                score: score,
                totalScore: total
            )
        }
    }

    private func rebuildDailySections() {
        var rows = dailyData
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !q.isEmpty {
            rows = rows.filter { event in
                guard let entry = event["entry"] as? String else { return false }
                return entry.lowercased().contains(q.lowercased())
            }
        }
        rows.sort { a, b in
            let e1 = a["entry"] as? String ?? ""
            let e2 = b["entry"] as? String ?? ""
            return e1 < e2
        }

        var byDate: [String: [[String: Any]]] = [:]
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        let displayKeyFormatter = DateFormatter()
        displayKeyFormatter.dateFormat = "yyyy-MM-dd"
        displayKeyFormatter.locale = Locale(identifier: "en_US_POSIX")

        for entry in rows {
            var dayKey: String?
            if let raw = entry["createdAt"] as? String,
               let parsed = inputFormatter.date(from: raw) {
                dayKey = displayKeyFormatter.string(from: parsed)
            }
            guard let key = dayKey else { continue }
            byDate[key, default: []].append(entry)
        }

        let sortedKeys = byDate.keys.sorted(by: >)

        dailySections = sortedKeys.map { key in
            let header = Self.formatSectionHeaderDate(key) ?? key
            let items = byDate[key] ?? []
            let mapped: [JournalDailyRowPresentation] = items.enumerated().compactMap { idx, event in
                guard let created = event["createdAt"] as? String else { return nil }
                let body = event["entry"] as? String ?? ""
                let time = Self.formatDailyTime(created) ?? created
                let id = "\(key)|\(idx)|\(created)"
                return JournalDailyRowPresentation(
                    id: id,
                    createdAtRaw: created,
                    timeText: time,
                    bodyText: body
                )
            }
            return JournalDailySectionPresentation(id: key, headerText: header, rows: mapped)
        }
    }

    private func rebuildDiscoveryRows() {
        var rows = discoverData
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !q.isEmpty {
            rows = rows.filter { event in
                guard let entry = event["entry"] as? String else { return false }
                return entry.lowercased().contains(q.lowercased())
            }
        }
        rows.sort { a, b in
            let e1 = a["entry"] as? String ?? ""
            let e2 = b["entry"] as? String ?? ""
            return e1 < e2
        }

        discoveryRows = rows.enumerated().compactMap { idx, event in
            guard let created = event["createdAt"] as? String,
                  let entryTitle = event["entry"] as? String else { return nil }
            let dateText = Self.formatDiscoveryDate(created) ?? created
            let bullets = DrinkingData.shared[entryTitle]?.1 ?? []
            let id = "\(idx)|\(created)|\(entryTitle)"
            return JournalDiscoveryRowPresentation(
                id: id,
                createdAtRaw: created,
                dateText: dateText,
                entryTitle: entryTitle,
                bodyPreview: entryTitle,
                bulletLines: bullets
            )
        }
    }

    // MARK: - Formatting

    private static func quizCompletionDate(from raw: String?) -> Date? {
        guard let raw, !raw.isEmpty else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: raw)
    }

    private static func formatQuizDateTime(_ dateTime: String) -> String? {
        let input = DateFormatter()
        input.dateFormat = "yyyy-MM-dd HH:mm:ss"
        input.locale = Locale(identifier: Utility.shared.getLocaleIdentifier())

        let output = DateFormatter()
        output.dateFormat = "MM/dd/yyyy | hh:mm a"
        output.locale = Locale(identifier: Utility.shared.getLocaleIdentifier())
        output.timeZone = TimeZone.current

        guard let date = input.date(from: dateTime) else { return nil }
        return output.string(from: date)
    }

    private static func formatSectionHeaderDate(_ yyyyMMdd: String) -> String? {
        let input = DateFormatter()
        input.dateFormat = "yyyy-MM-dd"
        input.locale = Locale(identifier: "en_US_POSIX")

        let output = DateFormatter()
        output.dateFormat = "MM/dd/yyyy"
        output.locale = Locale(identifier: Utility.shared.getLocaleIdentifier())

        guard let date = input.date(from: yyyyMMdd) else { return nil }
        return output.string(from: date)
    }

    private static func formatDailyTime(_ isoDateString: String) -> String? {
        let input = DateFormatter()
        input.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        input.locale = Locale(identifier: "en_US_POSIX")

        let output = DateFormatter()
        output.dateFormat = "hh:mm a"
        output.locale = Locale(identifier: Utility.shared.getLocaleIdentifier())
        output.timeZone = TimeZone.current

        guard let date = input.date(from: isoDateString) else { return nil }
        return output.string(from: date)
    }

    private static func formatDiscoveryDate(_ isoDateString: String) -> String? {
        let input = DateFormatter()
        input.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        input.locale = Locale(identifier: "en_US_POSIX")

        let output = DateFormatter()
        output.dateFormat = "MM/dd/yyyy"
        output.locale = Locale(identifier: Utility.shared.getLocaleIdentifier())

        guard let date = input.date(from: isoDateString) else { return nil }
        return output.string(from: date)
    }

    // MARK: - Empty state

    var showsEmptyPlaceholder: Bool {
        switch selectedSegment {
        case .questionnaire:
            return quizRows.isEmpty
        case .diary:
            return dailySections.flatMap(\.rows).isEmpty
        case .discovery:
            return discoveryRows.isEmpty
        }
    }

    var showsAddFloatingButton: Bool {
        selectedSegment == .diary
    }

    #if DEBUG
    func applyPreviewState(
        segment: JournalEntrySegment,
        quiz: [JournalQuizRowPresentation],
        daily: [JournalDailySectionPresentation],
        discovery: [JournalDiscoveryRowPresentation]
    ) {
        selectedSegment = segment
        quizRows = quiz
        dailySections = daily
        discoveryRows = discovery
        searchText = ""
        isOffline = true
        reloadLocalizedChrome()
    }
    #endif
}
