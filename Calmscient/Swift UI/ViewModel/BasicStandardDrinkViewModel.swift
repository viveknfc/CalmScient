//
//  BasicStandardDrinkViewModel.swift
//  Calmscient
//
//  State, API, and navigation for the standard drink carousel (parity with `BasicStandardDrink`).
//
//  Vivek
//  21 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class BasicStandardDrinkViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var carouselItems: [StandardDrinkCarouselItemPresentation] = []
    @Published private(set) var currentCarouselIndex = 0
    @Published private(set) var introAttributedText: AttributedString = AttributedString()
    @Published private(set) var isLoading = false
    @Published private(set) var isCompleting = false

    private(set) var navigationChromeTitle: String = ""
    private(set) var headerTitle: String = ""
    private(set) var bodyDescriptionText: String = ""
    private(set) var completeButtonTitle: String = ""

    private(set) var sectionId: Int = 0

    private var anchorView: UIView? { hostViewController?.view }

    func configure(sectionId: Int, navigationTitle: String? = nil) {
        self.sectionId = sectionId
        if let navigationTitle, !navigationTitle.isEmpty {
            navigationChromeTitle = navigationTitle
        }
    }

    private var navigationController: UINavigationController? {
        hostViewController?.navigationController
    }

    private var tabBarController: UITabBarController? {
        hostViewController?.tabBarController
    }

    var currentCarouselItem: StandardDrinkCarouselItemPresentation? {
        guard !carouselItems.isEmpty,
              carouselItems.indices.contains(currentCarouselIndex) else {
            return nil
        }
        return carouselItems[currentCarouselIndex]
    }

    var canShowPreviousCarouselItem: Bool {
        !carouselItems.isEmpty && currentCarouselIndex > 0
    }

    var canShowNextCarouselItem: Bool {
        !carouselItems.isEmpty && currentCarouselIndex < carouselItems.count - 1
    }

    func onHostViewDidLoad() {
        reloadLocalizedStrings()
        fetchDrinksList()
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = false
    }

    func reloadLocalizedStrings() {
        navigationChromeTitle = "Basic Knowledge".localized
        headerTitle = "What\u{2019}s a standard drink".localized
        bodyDescriptionText = "standard drink description2".localized
        completeButtonTitle = "Complete".localized

        let introBodyFont = LoginDesignSystem.Typography.lexendLight(size: 14)
        introAttributedText = BasicStandardDrinkPresentation.makeIntroAttributedText(
            fullText: "standard drink description".localized,
            bodyFont: introBodyFont
        )
    }

    func openBack() {
        navigationController?.popViewController(animated: true)
    }

    func showPreviousCarouselItem() {
        guard canShowPreviousCarouselItem else { return }
        currentCarouselIndex -= 1
    }

    func showNextCarouselItem() {
        guard canShowNextCarouselItem else { return }
        currentCarouselIndex += 1
    }

    func completeTapped() {
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

        APIService.DUpdateBasicKAPICalling(
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

    // MARK: - API

    private func fetchDrinksList() {
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken,
              let host = hostViewController else {
            return
        }

        isLoading = true
        anchorView?.showToastActivity()

        let params: [String: Any] = [
            "plId": userInfo.patientLocationID,
            "patientId": userInfo.patientID,
            "clientId": userInfo.clientID,
            "activityDate": "",
        ]

        APIService.getDrinksListAPICalling(
            host,
            params: params,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] result in
            Task { @MainActor in
                self?.handleFetchResponse(result)
            }
        }
    }

    private func handleFetchResponse(_ response: AnyObject) {
        isLoading = false
        anchorView?.hideToastActivity()

        if let errorMessage = response as? String, errorMessage.contains("No Internet") {
            return
        }

        guard let responseDict = response as? [String: Any] else { return }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: responseDict, options: [])
            let decoded = try JSONDecoder().decode(DrinkingCountDrinksListResponse.self, from: jsonData)
            carouselItems = StandardDrinkCarouselItemPresentation.carouselItems(
                from: decoded.drinksList ?? []
            )
            currentCarouselIndex = 0
        } catch {
            print("BasicStandardDrinkViewModel: decode error — \(error)")
        }
    }

    private func handleCompleteResponse(_ response: AnyObject) {
        isCompleting = false
        anchorView?.hideToastActivity()

        guard response is [String: Any] else {
            print("BasicStandardDrinkViewModel: unsupported complete response — \(type(of: response))")
            return
        }

        openBack()
    }

    #if DEBUG
    func applyPreviewState(
        items: [StandardDrinkCarouselItemPresentation],
        currentIndex: Int = 0
    ) {
        reloadLocalizedStrings()
        carouselItems = items
        currentCarouselIndex = min(max(0, currentIndex), max(0, items.count - 1))
        isLoading = false
        isCompleting = false
    }
    #endif
}

// MARK: - Navigation

@available(iOS 16.0, *)
enum BasicStandardDrinkNavigation {

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

        let standardDrinkHost = BasicStandardDrinkHostingController()
        standardDrinkHost.viewModel.configure(sectionId: sectionId, navigationTitle: navigationTitle)
        nav.pushViewController(standardDrinkHost, animated: animated)
    }
}
