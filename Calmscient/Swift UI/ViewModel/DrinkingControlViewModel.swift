//
//  DrinkingControlViewModel.swift
//  Calmscient
//
//  State, API, and navigation for the Drinking tab (parity with legacy `DrinkingControl`).
//
//  Vivek
//  20 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class DrinkingControlViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var statCards: [TakingControlStatCardPresentation] = []
    @Published private(set) var menuItems: [TakingControlMenuItemPresentation] = []
    @Published private(set) var resourceRows: [TakingControlResourceRowPresentation] = []
    @Published private(set) var calendarEvents: [TakingControlCalendarEventPresentation] = []
    @Published var selectedCalendarDate: Date = Calendar.current.startOfDay(for: Date())
    @Published var showsInfoPopover = false
    @Published private(set) var isLoading = false
    @Published private(set) var needToTalkButtonTitle: String = ""

    var infoLegendItems: [TakingControlInfoLegendItem] {
        TakingControlIndexPresentation.drinkingInfoLegend()
    }

    var presentFullDatePickerFromBottom: (() -> Void)?

    private var anchorView: UIView? { hostViewController?.view }

    func reloadLocalizedStrings() {
        needToTalkButtonTitle = "Need to talk with someone?".localized
        menuItems = [
            TakingControlMenuItemPresentation(id: 0, title: "Basic Knowledge".localized, isActive: true, showsCheckmark: false),
            TakingControlMenuItemPresentation(id: 1, title: "Make a plan".localized, isActive: false, showsCheckmark: false),
            TakingControlMenuItemPresentation(id: 2, title: "Stay focused".localized, isActive: false, showsCheckmark: false),
            TakingControlMenuItemPresentation(id: 3, title: "My progress".localized, isActive: false, showsCheckmark: false),
        ]
        resourceRows = [
            TakingControlResourceRowPresentation(
                id: 0,
                title: "Breathing exercises".localized,
                description: "SMOKING_CONTROL_RESOURCE_BREATHING_DESC".localized,
                imageName: "BreathingTechnic"
            ),
            TakingControlResourceRowPresentation(
                id: 1,
                title: "SMOKING_CONTROL_RESOURCE_MANAGING_ANXIETY_TITLE".localized,
                description: "SMOKING_CONTROL_RESOURCE_MANAGING_ANXIETY_DESC".localized,
                imageName: "img1"
            ),
            TakingControlResourceRowPresentation(
                id: 2,
                title: "Screenings".localized,
                description: "SMOKING_CONTROL_RESOURCE_SCREENINGS_DESC".localized,
                imageName: "Screening_Cell"
            ),
            TakingControlResourceRowPresentation(
                id: 3,
                title: "Drink counts calculator".localized,
                description: "DRINKING_CONTROL_RESOURCE_CALCULATOR_DESC".localized,
                imageName: "SummaryOfAudit"
            ),
        ]
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
        fetchTakingControlIndex()
    }

    func selectCalendarDate(_ date: Date) {
        selectedCalendarDate = Calendar.current.startOfDay(for: date)
    }

    func monthYearNavigationTitle(for date: Date) -> String {
        MedicalCalendarStripLogic.monthYearNavigationTitle(for: date)
    }

    func weekDays() -> [Date] {
        TakingControlCalendarStripLogic.weekDays(containing: selectedCalendarDate)
    }

    func isStripDaySelected(_ day: Date) -> Bool {
        MedicalCalendarStripLogic.isStripDaySelected(day, selected: selectedCalendarDate)
    }

    func stripDayIdentifier(for day: Date) -> String {
        MedicalCalendarStripLogic.stripDayIdentifier(for: day)
    }

    func eventColor(for day: Date) -> Color? {
        let id = stripDayIdentifier(for: day)
        return calendarEvents.first(where: { $0.id == id })?.dotColor
    }

    func toggleInfoPopover() {
        showsInfoPopover.toggle()
    }

    func dismissInfoPopover() {
        showsInfoPopover = false
    }

    // MARK: - Actions

    func openMenuItem(at index: Int) {
        switch index {
        case 0:
            openBasicKnowledge()
        default:
            presentComingSoon()
        }
    }

    func openDrinkTracker() { presentComingSoon() }
    func openEventsTracker() { presentComingSoon() }
    func openNeedToTalk() { pushNeedToTalk() }

    func openResource(at index: Int) {
        guard let host = hostViewController else { return }
        switch index {
        case 0:
            BreathingTechniqueNavigation.push(from: host)
        case 1:
            ManagingAnxietyBeginNavigation.push(from: host)
        case 2:
            let hostList = ScreeningListHostingController()
            hostList.configure(isComingFromParticularVC: true)
            host.navigationController?.pushViewController(hostList, animated: true)
        case 3:
            DrinkingCountNavigation.push(from: host)
        default:
            break
        }
    }

    // MARK: - API

    func fetchTakingControlIndex() {
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken,
              let host = hostViewController else {
            return
        }

        isLoading = true
        anchorView?.showToastActivity()

        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let currentDateString = formatter.string(from: Date())

        let params: [String: Any] = [
            "patientId": userInfo.patientID,
            "plId": userInfo.patientLocationID,
            "clientId": userInfo.clientID,
            "date": currentDateString,
        ]

        APIService.getTakingControlIndexAPICalling(
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

        guard let responseDict = response as? [String: Any] else { return }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: responseDict, options: [])
            let data = try JSONDecoder().decode(DrinkingTakingControlResponse.self, from: jsonData)
            applyResponse(data)
            
            print("the drinkind data is: \(data)")
        } catch {
            print("DrinkingControlViewModel: decode error — \(error)")
        }
    }

    private func applyResponse(_ data: DrinkingTakingControlResponse) {
        calendarEvents = TakingControlIndexPresentation.calendarEvents(from: data.intoDates)
        if calendarEvents.isEmpty {
            calendarEvents = TakingControlIndexPresentation.previewCalendarEvents(around: selectedCalendarDate)
        }

        guard let indexes = data.index, indexes.count >= 2 else {
            statCards = defaultStatCards()
            return
        }

        statCards = [
            TakingControlStatCardPresentation(
                id: "left",
                title: indexes[0].goalType ?? "Drink Counts".localized,
                value: "\(indexes[0].goal ?? 0)",
                subtitle: nil,
                systemImageName: "arrow.counterclockwise.circle",
                assetImageName: "now"
            ),
            TakingControlStatCardPresentation(
                id: "right",
                title: indexes[1].goalType ?? "Alcohol free days".localized,
                value: "\(indexes[1].goal ?? 0)",
                subtitle: indexes[1].goalDescription,
                systemImageName: nil,
                assetImageName: "alcoholImage"
            ),
        ]
    }

    private func defaultStatCards() -> [TakingControlStatCardPresentation] {
        [
            TakingControlStatCardPresentation(
                id: "left",
                title: "Drink Counts".localized,
                value: "0",
                subtitle: nil,
                systemImageName: "arrow.counterclockwise.circle",
                assetImageName: nil
            ),
            TakingControlStatCardPresentation(
                id: "right",
                title: "Alcohol free days".localized,
                value: "0",
                subtitle: nil,
                systemImageName: nil,
                assetImageName: "alcoholImage"
            ),
        ]
    }

    private func openBasicKnowledge() {
        guard let host = hostViewController else { return }
        BasicKnowledgeNavigation.push(from: host)
    }

    private func presentComingSoon() {
        guard let host = hostViewController else { return }
        FullComingSoonViewModel.present(from: host)
    }

    private func pushNeedToTalk() {
        guard let host = hostViewController else { return }
        NeedToTalkNavigation.push(from: host)
    }

    #if DEBUG
    func applyPreviewState(
        statCards: [TakingControlStatCardPresentation],
        calendarEvents: [TakingControlCalendarEventPresentation]
    ) {
        reloadLocalizedStrings()
        self.statCards = statCards
        self.calendarEvents = calendarEvents
    }
    #endif
}
