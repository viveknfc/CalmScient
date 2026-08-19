//
//  DrinkingCountViewModel.swift
//  Calmscient
//
//  State, API, and navigation for drink counts calculator (parity with `DrinkingCountVC`).
//
//  Vivek
//  21 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class DrinkingCountViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var drinkRows: [DrinkCountRowPresentation] = []
    @Published private(set) var displayedTotalCount: String = "0"
    @Published private(set) var showsSaveButton = false
    @Published private(set) var isLoading = false
    @Published private(set) var isSaving = false

    private(set) var navigationChromeTitle: String = ""
    private(set) var subtitleText: String = ""
    private(set) var totalLabelLineOne: String = ""
    private(set) var totalLabelLineTwo: String = ""
    private(set) var selectionInstructionText: String = ""
    private(set) var saveButtonTitle: String = ""

    private var baselineTotalFromAPI: Double = 0
    private var sessionDeltaTotal: Double = 0
    private var alcoholChangePayload: [[String: Any]] = []

    private var anchorView: UIView? { hostViewController?.view }

    func onHostViewDidLoad() {
        reloadLocalizedStrings()
        fetchDrinksList()
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = false
        // Removed: this hard-coded the *Home* tab label onto whichever tab was
        // selected, renaming the Discovery tab. `MainTabStoryboardHost.updateUIViewController`
        // already restores each tab's correct title.
    }

    func reloadLocalizedStrings() {
        navigationChromeTitle = "Drink counts calculator".localized
        subtitleText = "Now let's see what drinking habits do you have".localized
        totalLabelLineOne = "DRINKING_CONTROL_Total".localized
        totalLabelLineTwo = "DRINKING_CONTROL_Count".localized
        selectionInstructionText = "DRINKING_COUNT_SELECT_DRINK_INSTRUCTION".localized
        saveButtonTitle = "Save".localized
    }

    func openBack() {
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    func incrementQuantity(for drinkID: Int) {
        guard let index = drinkRows.firstIndex(where: { $0.id == drinkID }) else { return }
        let step = drinkRows[index].incrementCount
        var row = drinkRows[index]
        row.quantity += step
        applyRowUpdate(at: index, row: row)
        sessionDeltaTotal += step
        refreshDisplayedTotal()
        showsSaveButton = true
        recordAlcoholChange(
            drinkID: drinkID,
            newQuantity: row.quantity,
            incrementStep: step
        )
    }

    func decrementQuantity(for drinkID: Int) {
        guard let index = drinkRows.firstIndex(where: { $0.id == drinkID }) else { return }
        let step = drinkRows[index].incrementCount
        var row = drinkRows[index]
        guard row.quantity > 0 else { return }
        row.quantity = max(0, row.quantity - step)
        applyRowUpdate(at: index, row: row)
        sessionDeltaTotal -= step
        refreshDisplayedTotal()
        showsSaveButton = true
        recordAlcoholChange(
            drinkID: drinkID,
            newQuantity: row.quantity,
            incrementStep: step,
            isDecrement: true
        )
    }

    /// Reassigns the row array so `@Published` emits and SwiftUI refreshes cards (in-place subscript edits are unreliable).
    private func applyRowUpdate(at index: Int, row: DrinkCountRowPresentation) {
        var rows = drinkRows
        rows[index] = row
        drinkRows = rows
    }

    func saveDrinkCounts() {
        guard let host = hostViewController,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }

        isSaving = true
        anchorView?.showToastActivity()

        let params: [String: Any] = ["alcohol": alcoholChangePayload]

        APIService.createDrinkingCountAPICalling(
            host,
            params: params,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] result in
            Task { @MainActor in
                self?.handleSaveResponse(result)
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
            applyDrinksList(decoded)
        } catch {
            print("DrinkingCountViewModel: decode error — \(error)")
        }
    }

    private func applyDrinksList(_ response: DrinkingCountDrinksListResponse) {
        baselineTotalFromAPI = response.totalCount?.value ?? 0
        sessionDeltaTotal = 0
        alcoholChangePayload = []
        showsSaveButton = false

        drinkRows = (response.drinksList ?? []).compactMap { item in
            guard let drinkID = item.drinkId else { return nil }
            let imageURL = item.imageUrl.flatMap { URL(string: $0) }
            return DrinkCountRowPresentation(
                id: drinkID,
                drinkName: item.drinkName ?? "",
                imageURL: imageURL,
                incrementCount: item.incrementCount?.value ?? 1,
                quantity: item.quantity?.value ?? 0
            )
        }

        refreshDisplayedTotal()
    }

    private func handleSaveResponse(_ response: AnyObject) {
        isSaving = false
        anchorView?.hideToastActivity()

        guard let responseDict = response as? [String: Any],
              let statusResponse = responseDict["statusResponse"] as? [String: Any],
              let responseMessage = statusResponse["responseMessage"] as? String else {
            return
        }

        hostViewController?.showSuccessAlert(successContent: responseMessage, centreImage: nil) { [weak self] in
            self?.openBack()
        }
    }

    // MARK: - Alcohol change tracking

    private func recordAlcoholChange(
        drinkID: Int,
        newQuantity: Double,
        incrementStep: Double,
        isDecrement: Bool = false
    ) {
        let flag: String
        if isDecrement {
            flag = "U"
        } else {
            flag = abs(newQuantity - incrementStep) < 0.001 ? "I" : "U"
        }
        upsertAlcoholPayload(drinkID: drinkID, newQuantity: newQuantity, flag: flag)
    }

    private func upsertAlcoholPayload(drinkID: Int, newQuantity: Double, flag: String) {
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else { return }
        let currentDate = Self.currentActivityDateString()

        if let index = alcoholChangePayload.firstIndex(where: { ($0["drinkId"] as? Int) == drinkID }) {
            alcoholChangePayload[index]["quantity"] = newQuantity
            alcoholChangePayload[index]["flag"] = flag
            alcoholChangePayload[index]["activityDate"] = currentDate
        } else {
            alcoholChangePayload.append([
                "flag": flag,
                "plId": userInfo.patientLocationID,
                "trackingId": 1,
                "patientId": userInfo.patientID,
                "clientId": userInfo.clientID,
                "quantity": newQuantity,
                "drinkId": drinkID,
                "activityDate": currentDate,
            ])
        }
    }

    private func refreshDisplayedTotal() {
        let finalTotal = sessionDeltaTotal + baselineTotalFromAPI
        displayedTotalCount = DrinkCountRowPresentation.formatCount(finalTotal)
    }

    private static func currentActivityDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: Date())
    }

    private var navigationController: UINavigationController? {
        hostViewController?.navigationController
    }

    private var tabBarController: UITabBarController? {
        hostViewController?.tabBarController
    }

    #if DEBUG
    func applyPreviewState(
        rows: [DrinkCountRowPresentation],
        baselineTotal: Double = 0,
        sessionDelta: Double = 0,
        showsSave: Bool = false
    ) {
        reloadLocalizedStrings()
        drinkRows = rows
        baselineTotalFromAPI = baselineTotal
        sessionDeltaTotal = sessionDelta
        showsSaveButton = showsSave
        refreshDisplayedTotal()
    }
    #endif
}

@available(iOS 16.0, *)
enum DrinkingCountNavigation {

    static func push(from host: UIViewController, animated: Bool = true) {
        guard let nav = host.navigationController else { return }
        let drinkingCountHost = DrinkingCountHostingController()
        nav.pushViewController(drinkingCountHost, animated: animated)
    }
}
