//
//  DiscoveryMainViewModel.swift
//  Calmscient
//
//  State and navigation for the SwiftUI Discovery hub (parity with `DiscoveryMainViewController`).
//
//  Vivek
//  19 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class DiscoveryMainViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var screenTitle: String = ""
    @Published private(set) var rows: [DiscoveryMainRowPresentation] = []
    @Published private(set) var isLoadingTakingControl = false

    init() {
        reloadLocalizedStrings()
    }

    func reloadLocalizedStrings() {
        screenTitle = "Discovery".localized
        rows = [
            DiscoveryMainRowPresentation(id: 0, title: "Managing anxiety".localized, imageName: "img1"),
            DiscoveryMainRowPresentation(id: 1, title: "Changing your response to stress".localized, imageName: "img2"),
            DiscoveryMainRowPresentation(id: 2, title: "Taking control".localized, imageName: "img3"),
        ]
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
    }

    func openProfile() {
        guard let nav = hostViewController?.navigationController else { return }
        let profile = UserProfileHostingController()
        UserDefaults.standard.set(true, forKey: "shouldPopToDis")
        nav.pushViewController(profile, animated: true)
    }

    func openCitationSources() {
        guard let nav = hostViewController?.navigationController else { return }
        CitationWebNavigation.pushSourcesAndCitations(from: nav)
    }

    func openRow(at index: Int) {
        guard let nav = hostViewController?.navigationController else { return }
        switch index {
        case 0:
            openManagingAnxiety()
        case 1:
            openChangingStressResponse(on: nav)
        case 2:
            fetchTakingControlIndexAndNavigate()
        default:
            break
        }
    }

    private func openManagingAnxiety() {
        guard let host = hostViewController else { return }
        ManagingAnxietyBeginNavigation.push(from: host)
    }

    private func openChangingStressResponse(on nav: UINavigationController) {
        guard let host = hostViewController else { return }
        CoursesNavigation.push(
            courseID: 3,
            title: "Changing your response to stress".localized,
            from: host
        )
    }

    func fetchTakingControlIndexAndNavigate() {
        guard !isLoadingTakingControl else { return }
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }

        isLoadingTakingControl = true
        hostViewController?.view.showToastActivity()

        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let currentDateString = formatter.string(from: Date())

        let params: [String: Any] = [
            "patientId": userInfo.patientID,
            "plId": userInfo.patientLocationID,
            "clientId": userInfo.clientID,
            "date": currentDateString,
        ]

        guard let host = hostViewController else {
            isLoadingTakingControl = false
            return
        }

        APIService.getTakingControlIndexAPICalling(
            host,
            params: params,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoadingTakingControl = false
                self.hostViewController?.view.hideToastActivity()
                self.handleTakingControlIndexResponse(response)
            }
        }
    }

    private func handleTakingControlIndexResponse(_ response: AnyObject) {
        guard let host = hostViewController,
              host.navigationController != nil else { return }

        if let responseDict = response as? [String: Any] {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: responseDict, options: [])
                let data = try JSONDecoder().decode(DrinkingTakingControlResponse.self, from: jsonData)
                guard let firstCourse = data.courseLists?.first else { return }

                let skipTutorial = firstCourse.skipTutorialFlag ?? 0
                TakingControlIndexNavigation.push(
                    from: host,
                    initialSegment: 0,
                    moveToIntro: skipTutorial == 0
                )
            } catch {
                print("DiscoveryMainViewModel: error decoding taking control index — \(error)")
            }
        }
    }
}
