//
//  TakingIntroLastViewModel.swift
//  Calmscient
//
//  State, navigation, and save-preference API for the Taking Control intro last screen
//  (parity with `TakingIntroLastVC`).
//
//  Vivek
//  20 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class TakingIntroLastViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var screenTitle: String = ""
    @Published private(set) var thankYouAttributed: AttributedString = AttributedString()
    @Published private(set) var dustSectionText: String = ""
    @Published private(set) var smokingSectionText: String = ""
    @Published private(set) var footerText: String = ""
    @Published private(set) var checkboxLabelText: String = ""
    @Published private(set) var drinkingCoachButtonTitle: String = ""
    @Published private(set) var notifyPcpButtonTitle: String = ""
    @Published private(set) var smokingCoachButtonTitle: String = ""
    @Published var isDoNotShowAgainOn: Bool = false

    private let headingFont = LoginDesignSystem.Typography.lexendLight(size: 14)
    private let bodyFont = LoginDesignSystem.Typography.lexendLight(size: 14)

    private var anchorView: UIView? { hostViewController?.view }

    init() {
        reloadLocalizedStrings()
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
    }

    func reloadLocalizedStrings() {
        screenTitle = TakingIntroLastLocalization.screenTitle.localized

        let thankYouFull = TakingIntroLastLocalization.thankYouMessage.localized
        let thankYouHeading = TakingIntroLastLocalization.thankYouHeading.localized
        thankYouAttributed = TakingIntroLastPresentation.makeThankYouAttributedText(
            fullText: thankYouFull,
            headingSubstring: thankYouHeading,
            headingFont: headingFont,
            bodyFont: bodyFont
        )

        dustSectionText = TakingIntroLastLocalization.dustSection.localized
        smokingSectionText = TakingIntroLastLocalization.smokingSection.localized
        footerText = TakingIntroLastLocalization.footerRetake.localized
        checkboxLabelText = TakingIntroLastLocalization.doNotShowAgain.localized

        drinkingCoachButtonTitle = TakingIntroLastLocalization.drinkingCoachButton.localized
        notifyPcpButtonTitle = TakingIntroLastLocalization.notifyPcpButtonKeyPhrase.localized
        smokingCoachButtonTitle = TakingIntroLastLocalization.smokingCoachButton.localized
    }

    /// Navigation bar back: push Taking Control index, Drinking segment (parity with storyboard nav back).
    func openNavigationBack() {
        pushTakingControlIndex(segment: 0)
    }

    /// Floating back: pop one level (parity with storyboard FAB).
    func openFloatingBack() {
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    func openDrinkingCoach() {
        pushTakingControlIndex(segment: 0)
    }

    func openNotifyPCP() {
        // Intentionally empty in `TakingIntroLastVC`; kept for parity.
    }

    func openSmokingCoach() {
        pushTakingControlIndex(segment: 1)
    }

    func setDoNotShowAgain(isOn: Bool) {
        isDoNotShowAgainOn = isOn
        if isOn {
            saveDoNotShowTutorialPreference()
        }
    }

    // MARK: - Private

    private func pushTakingControlIndex(segment: Int) {
        guard let host = hostViewController else { return }
        TakingControlIndexNavigation.push(from: host, initialSegment: segment)
    }

    private func saveDoNotShowTutorialPreference() {
        guard let host = hostViewController else { return }
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            return
        }
        guard let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }

        anchorView?.showToastActivity()

        let params: [String: Any] = [
            "clientId": userInfo.clientID,
            "patientId": userInfo.patientID,
            "plId": userInfo.patientLocationID,
            "introductionFlag": NSNull(),
            "auditFlag": NSNull(),
            "dastFlag": NSNull(),
            "cageFlag": NSNull(),
            "tutorialFlag": 0,
        ]

        APIService.saveTakingControlIntroAPICalling(
            host,
            params: params,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleSaveTakingControlIntroResponse(response)
            }
        }
    }

    private func handleSaveTakingControlIntroResponse(_ response: AnyObject) {
        anchorView?.hideToastActivity()

        if let responseDict = response as? [String: Any],
           let statusResponse = responseDict["statusResponse"] as? [String: Any],
           let responseMessage = statusResponse["responseMessage"] as? String {
            _ = responseMessage
        } else {
            print("TakingIntroLastViewModel: invalid saveTakingControlIntro response format.")
        }
    }

    #if DEBUG
    func applyPreviewState(
        thankYou: String = "Thank you for taking the test.\n\nBody.",
        heading: String = "Thank you for taking the test."
    ) {
        thankYouAttributed = TakingIntroLastPresentation.makeThankYouAttributedText(
            fullText: thankYou,
            headingSubstring: heading,
            headingFont: headingFont,
            bodyFont: bodyFont
        )
        dustSectionText = "DUST section preview."
        smokingSectionText = "Smoking section preview."
        footerText = "Footer preview."
        checkboxLabelText = "Checkbox label preview."
        drinkingCoachButtonTitle = "Drinking Coach"
        notifyPcpButtonTitle = "Notify to PCP"
        smokingCoachButtonTitle = "Smoking Coach"
        isDoNotShowAgainOn = false
    }
    #endif
}
