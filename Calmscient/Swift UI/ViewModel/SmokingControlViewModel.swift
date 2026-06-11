//
//  SmokingControlViewModel.swift
//  Calmscient
//
//  State, API, and navigation for the Smoking tab (parity with legacy `SmokingControl`).
//
//  Vivek
//  20 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class SmokingControlViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var statCards: [TakingControlStatCardPresentation] = []
    @Published private(set) var menuItems: [TakingControlMenuItemPresentation] = []
    @Published private(set) var resourceRows: [TakingControlResourceRowPresentation] = []
    @Published private(set) var isLoading = false
    @Published private(set) var needToTalkButtonTitle: String = ""
    @Published private(set) var resourcesSectionTitle: String = ""

    private var anchorView: UIView? { hostViewController?.view }

    func reloadLocalizedStrings() {
        needToTalkButtonTitle = "Need to talk with someone?".localized
        resourcesSectionTitle = "Resources".localized
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
        ]
        if statCards.isEmpty {
            statCards = defaultStatCards()
        }
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
        fetchSmokingTakingControl()
    }

    // MARK: - Actions

    func openMenuItem(at index: Int) {
        if index == 0 {
            openBasicKnowledge()
        } else {
            presentComingSoon()
        }
    }

    func openResource(at index: Int) {
        guard let host = hostViewController else { return }
        switch index {
        case 0:
            BreathingTechniqueNavigation.push(from: host)
        case 1:
            ManagingAnxietyBeginNavigation.push(from: host)
        case 2:
            let hostList = ScreeningListHostingController()
            hostList.configure(isComingFromParticularVC1: true)
            host.navigationController?.pushViewController(hostList, animated: true)
        default:
            break
        }
    }

    func openNeedToTalk() {
        guard let host = hostViewController else { return }
        let storyboard = UIStoryboard(name: "NeedToTalkViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "NeedToTalkViewController") as? NeedToTalkViewController else {
            return
        }
        vc.title = "Emergency resource"
        host.navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - API

    func fetchSmokingTakingControl() {
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken,
              let host = hostViewController else {
            return
        }

        isLoading = true
        anchorView?.showToastActivity()

        let params: [String: Any] = [
            "plId": userInfo.patientLocationID,
            "clientId": userInfo.clientID,
            "patientId": userInfo.patientID,
            "date": "",
        ]

        APIService.SGetTakingControlAPICalling(
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

        if let responseDict = response as? [String: Any] {
            
            print("smoking control data is ", responseDict)
            
            parseCourseLists(from: responseDict)
            parseIndexStats(from: responseDict)
        }
    }

    private func parseCourseLists(from responseDict: [String: Any]) {
        guard let indexArray = responseDict["courseLists"] as? [[String: Any]] else { return }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: indexArray, options: [])
            let courses = try JSONDecoder().decode([Course].self, from: jsonData)
            menuItems = courses.enumerated().map { offset, course in
                TakingControlMenuItemPresentation(
                    id: offset,
                    title: course.courseName,
                    isActive: offset == 0,
                    showsCheckmark: course.isCompleted == 1
                )
            }
        } catch {
            print("SmokingControlViewModel: course decode error — \(error)")
        }
    }

    private func parseIndexStats(from responseDict: [String: Any]) {
        guard let indexArray = responseDict["index"] as? [[String: Any]],
              indexArray.count >= 2 else {
            return
        }

        let leftGoal = indexArray[0]["goal"] as? Int ?? 0
        let leftType = indexArray[0]["goalType"] as? String ?? "Smoking free time".localized
        let rightGoal = indexArray[1]["goal"] as? Int ?? 0
        let rightType = indexArray[1]["goalType"] as? String ?? "Saving".localized
        let rightSubtitle = indexArray[1]["goalDescription"] as? String ?? "USD($)".localized

        statCards = [
            TakingControlStatCardPresentation(
                id: "left",
                title: leftType,
                value: "\(leftGoal)",
                subtitle: "Days".localized,
                systemImageName: "calendar",
                assetImageName: "calenderi"
            ),
            TakingControlStatCardPresentation(
                id: "right",
                title: rightType,
                value: "\(rightGoal)",
                subtitle: rightSubtitle,
                systemImageName: "wallet.pass",
                assetImageName: "purse"
            ),
        ]
    }

    private func defaultStatCards() -> [TakingControlStatCardPresentation] {
        [
            TakingControlStatCardPresentation(
                id: "left",
                title: "Smoking free time".localized,
                value: "0",
                subtitle: "Days".localized,
                systemImageName: "calendar",
                assetImageName: nil
            ),
            TakingControlStatCardPresentation(
                id: "right",
                title: "Saving".localized,
                value: "0",
                subtitle: "USD($)".localized,
                systemImageName: "wallet.pass",
                assetImageName: nil
            ),
        ]
    }

    private func openBasicKnowledge() {
        guard let host = hostViewController else { return }
        SmokingBasicKnowledgeNavigation.push(from: host)
    }

    private func presentComingSoon() {
        guard let host = hostViewController else { return }
        FullComingSoonViewModel.present(from: host)
    }

    #if DEBUG
    func applyPreviewState(
        statCards: [TakingControlStatCardPresentation],
        menuItems: [TakingControlMenuItemPresentation]
    ) {
        reloadLocalizedStrings()
        self.statCards = statCards
        self.menuItems = menuItems
    }
    #endif
}
