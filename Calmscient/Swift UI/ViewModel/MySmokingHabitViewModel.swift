//
//  MySmokingHabitViewModel.swift
//  Calmscient
//
//  State, API, and navigation for My Smoking Habit (parity with `MySmokingHabitVC`).
//
//  Vivek
//  26 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class MySmokingHabitViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var stageCards: [SmokingHabitStageCardPresentation] = []
    @Published private(set) var isSavingJournal = false
    @Published private(set) var isCompleting = false

    private(set) var navigationChromeTitle: String = ""
    private(set) var headerTitle: String = ""
    private(set) var stageQuestion: String = ""
    private(set) var journalPrompt: String = ""
    private(set) var yesButtonTitle: String = ""
    private(set) var completeButtonTitle: String = ""

    private(set) var sectionId: Int = 0

    private var selectedRowIndex: Int?

    private var anchorView: UIView? { hostViewController?.view }

    private var navigationController: UINavigationController? {
        hostViewController?.navigationController
    }

    private var tabBarController: UITabBarController? {
        hostViewController?.tabBarController
    }

    func configure(sectionId: Int, navigationTitle: String? = nil) {
        self.sectionId = sectionId
        if let navigationTitle, !navigationTitle.isEmpty {
            navigationChromeTitle = navigationTitle
        }
    }

    func onHostViewDidLoad() {
        reloadLocalizedStrings()
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = false
    }

    func reloadLocalizedStrings() {
        if navigationChromeTitle.isEmpty {
            navigationChromeTitle = MySmokingHabitLocalization.navigationTitleKey.localized
        }
        headerTitle = MySmokingHabitLocalization.headerTitle.localized
        stageQuestion = MySmokingHabitLocalization.stageQuestion.localized
        journalPrompt = MySmokingHabitLocalization.journalPrompt.localized
        yesButtonTitle = MySmokingHabitLocalization.yesButton.localized
        completeButtonTitle = MySmokingHabitLocalization.completeButton.localized
        stageCards = MySmokingHabitPresentation.buildLocalizedCards(selectedIndex: selectedRowIndex)
    }

    func openBack() {
        navigationController?.popViewController(animated: true)
    }

    func selectStage(at index: Int) {
        guard stageCards.indices.contains(index) else { return }
        selectedRowIndex = index
        stageCards = MySmokingHabitPresentation.buildLocalizedCards(selectedIndex: index)
    }

    func yesTapped() {
        guard let index = selectedRowIndex,
              stageCards.indices.contains(index) else {
            showSelectStageAlert()
            return
        }

        guard let userInfo = ApplicationSharedInfo.shared.loginResponse,
              let host = hostViewController,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = df.string(from: Date())

        let params: [String: Any] = [
            "patientId": userInfo.patientID,
            "entry": stageCards[index].journalEntryValue,
            "plId": userInfo.patientLocationID,
            "clientId": userInfo.clientID,
            "entryType": "discovery_exercise",
            "createdAt": formattedDate,
        ]

        isSavingJournal = true
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

    func completeTapped() {
        guard selectedRowIndex != nil else {
            showSelectStageAlert()
            return
        }

        hostViewController?.showGeneralAlert(
            title: MySmokingHabitLocalization.completeGuideAlert.localized,
            okButtonTitle: MySmokingHabitLocalization.okButton.localized,
            okAction: { [weak self] in
                self?.performCompleteAPI()
            },
            showDismissButton: false
        )
    }

    private func performCompleteAPI() {
        guard let host = hostViewController,
              let userInfo = ApplicationSharedInfo.shared.loginResponse,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }

        isCompleting = true
        anchorView?.showToastActivity()

        let params: [String: Any] = [
            "isCompleted": 1,
            "patientId": userInfo.patientID,
            "sectionId": sectionId,
        ]

        APIService.SUpdateBasicKAPICalling(
            host,
            params: params,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleCompleteResponse(response)
            }
        }
    }

    private func handleAddJournalResponse(_ response: AnyObject) {
        isSavingJournal = false
        anchorView?.hideToastActivity()

        guard let responseDict = response as? [String: Any],
              let responseMessage = responseDict["responseMessage"] as? String else {
            return
        }

        hostViewController?.showSuccessAlert(successContent: responseMessage, centreImage: nil, okButtonAction: {})
    }

    private func handleCompleteResponse(_ response: AnyObject) {
        isCompleting = false
        anchorView?.hideToastActivity()

        guard response is [String: Any] else {
            print("MySmokingHabitViewModel: unsupported complete response — \(type(of: response))")
            return
        }

        openBack()
    }

    private func showSelectStageAlert() {
        hostViewController?.showGeneralAlert(
            image: UIImage(named: "InfoIcon"),
            imageSize: CGSize(width: 60, height: 60),
            title: MySmokingHabitLocalization.selectStageAlert.localized,
            okButtonTitle: MySmokingHabitLocalization.okButton.localized,
            okAction: {},
            dismissAction: {}
        )
    }

    #if DEBUG
    func applyPreviewState(selectedIndex: Int? = 0) {
        selectedRowIndex = selectedIndex
        reloadLocalizedStrings()
        isSavingJournal = false
        isCompleting = false
    }
    #endif
}

// MARK: - Navigation

@available(iOS 16.0, *)
enum MySmokingHabitNavigation {

    @MainActor
    static func push(
        from host: UIViewController,
        sectionId: Int,
        navigationTitle: String? = nil,
        animated: Bool = true
    ) {
        guard let nav = host.navigationController else { return }

        let backItem = UIBarButtonItem()
        backItem.title = ""
        host.navigationItem.backBarButtonItem = backItem

        let smokingHabitHost = MySmokingHabitHostingController()
        smokingHabitHost.viewModel.configure(sectionId: sectionId, navigationTitle: navigationTitle)
        nav.pushViewController(smokingHabitHost, animated: animated)
    }
}
