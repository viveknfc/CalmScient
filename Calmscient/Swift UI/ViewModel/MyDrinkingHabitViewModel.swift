//
//  MyDrinkingHabitViewModel.swift
//  Calmscient
//
//  State, API, and navigation for My Drinking Habit (parity with `MyDrinkingHabitVC`).
//
//  Vivek
//  25 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class MyDrinkingHabitViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var habitCards: [DrinkingHabitCardPresentation] = []
    @Published private(set) var isSavingJournal = false

    private(set) var navigationChromeTitle: String = ""
    private(set) var headerTitle: String = ""
    private(set) var habitQuestion: String = ""
    private(set) var moderateDefinitionIntro: String = ""
    private(set) var menLabel: String = ""
    private(set) var menLimit: String = ""
    private(set) var womenLabel: String = ""
    private(set) var womenLimit: String = ""
    private(set) var knowCountsPrompt: String = ""
    private(set) var calculatorButtonTitle: String = ""
    private(set) var journalPrompt: String = ""
    private(set) var yesButtonTitle: String = ""
    private(set) var forwardFabAccessibilityLabel: String = ""

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
            navigationChromeTitle = MyDrinkingHabitLocalization.navigationTitleKey.localized
        }
        headerTitle = MyDrinkingHabitLocalization.headerTitle.localized
        habitQuestion = MyDrinkingHabitLocalization.habitQuestion.localized
        moderateDefinitionIntro = MyDrinkingHabitLocalization.moderateDefinitionIntro.localized
        menLabel = MyDrinkingHabitLocalization.menLabel.localized
        menLimit = MyDrinkingHabitLocalization.menLimit.localized
        womenLabel = MyDrinkingHabitLocalization.womenLabel.localized
        womenLimit = MyDrinkingHabitLocalization.womenLimit.localized
        knowCountsPrompt = MyDrinkingHabitLocalization.knowCountsPrompt.localized
        calculatorButtonTitle = MyDrinkingHabitLocalization.calculatorButton.localized
        journalPrompt = MyDrinkingHabitLocalization.journalPrompt.localized
        yesButtonTitle = MyDrinkingHabitLocalization.yesButton.localized
        forwardFabAccessibilityLabel = MyDrinkingHabitLocalization.forwardFabAccessibility.localized
        habitCards = MyDrinkingHabitPresentation.buildLocalizedCards(selectedIndex: selectedRowIndex)
    }

    func openBack() {
        navigationController?.popViewController(animated: true)
    }

    func selectHabit(at index: Int) {
        guard habitCards.indices.contains(index) else { return }
        selectedRowIndex = index
        habitCards = MyDrinkingHabitPresentation.buildLocalizedCards(selectedIndex: index)
    }

    func openDrinkCountsCalculator() {
        guard let host = hostViewController else { return }
        let backItem = UIBarButtonItem()
        backItem.title = ""
        host.navigationItem.backBarButtonItem = backItem
        DrinkingCountNavigation.push(from: host)
    }

    func yesTapped() {
        guard let index = selectedRowIndex,
              habitCards.indices.contains(index) else {
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
            "entry": habitCards[index].journalEntryValue,
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

    func forwardTapped() {
        guard let index = selectedRowIndex else {
            showSelectStageAlert()
            return
        }

        guard let host = hostViewController,
              host.navigationController != nil else {
            return
        }

        let backItem = UIBarButtonItem()
        backItem.title = ""
        host.navigationItem.backBarButtonItem = backItem

        let screenTitle = navigationChromeTitle

        guard let variant = ModerateDrinkingEducationVariant(rawValue: index) else {
            showSelectStageAlert()
            return
        }

        ModerateDrinkingEducationNavigation.push(
            variant: variant,
            from: host,
            sectionId: sectionId,
            navigationTitle: screenTitle
        )
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

    private func showSelectStageAlert() {
        hostViewController?.showGeneralAlert(
            image: UIImage(named: "InfoIcon"),
            imageSize: CGSize(width: 60, height: 60),
            title: MyDrinkingHabitLocalization.selectStageAlert.localized,
            okButtonTitle: MyDrinkingHabitLocalization.okButton.localized,
            okAction: {},
            dismissAction: {}
        )
    }

    #if DEBUG
    func applyPreviewState(selectedIndex: Int? = 0) {
        selectedRowIndex = selectedIndex
        reloadLocalizedStrings()
        isSavingJournal = false
    }
    #endif
}

// MARK: - Navigation

@available(iOS 16.0, *)
enum MyDrinkingHabitNavigation {

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

        let drinkingHabitHost = MyDrinkingHabitHostingController()
        drinkingHabitHost.viewModel.configure(sectionId: sectionId, navigationTitle: navigationTitle)
        nav.pushViewController(drinkingHabitHost, animated: animated)
    }
}
