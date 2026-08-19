//
//  HealthDataRangeViewModel.swift
//  Calmscient
//
//  Loads `patients/api/v1/health/wearable-data/range` for the range picked on the
//  "Select Date(s)" screen and turns it into one card per day.
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class HealthDataRangeViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    // MARK: - SwiftUI navigation (UIKit push/pop stays the fallback)
    var onOpenRoute: ((HomeRoute) -> Void)?
    var onClose: (() -> Void)?
    var onCloseToRoot: (() -> Void)?

    let startDate: Date
    let endDate: Date

    @Published private(set) var days: [WearableRangeDayPresentation] = []
    @Published private(set) var isLoading = false
    @Published private(set) var hasLoaded = false

    init(startDate: Date, endDate: Date) {
        self.startDate = min(startDate, endDate)
        self.endDate = max(startDate, endDate)
    }

    var screenTitle: String { "Health Data".localized }

    /// "1 Jul 2026 - 14 Aug 2026" (single date when both ends match).
    var rangeText: String {
        let start = Self.headerFormatter.string(from: startDate)
        guard startDate != endDate else { return start }
        return "\(start) - \(Self.headerFormatter.string(from: endDate))"
    }

    private var patientId: Int? { ApplicationSharedInfo.shared.loginResponse?.patientID }
    private var accessToken: String? { ApplicationSharedInfo.shared.tokenResponse?.accessToken }

    // MARK: - Load

    func loadIfNeeded() {
        guard !hasLoaded, !isLoading else { return }
        load()
    }

    func load() {
        guard let patientId, let token = accessToken else {
            finish(with: [])
            hostViewController?.view.showToast(message: "An Unknown error occured. Please check with Admin".localized)
            return
        }

        isLoading = true
        hostViewController?.view.showToastActivity()

        let params: [String: Any] = [
            "patientId": patientId,
            "startDate": Self.apiFormatter.string(from: startDate),
            "endDate": Self.apiFormatter.string(from: endDate)
        ]

        APIService.getWearableDataRangeAPICalling(
            hostViewController,
            params: params,
            accessToken: token
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleResponse(response)
            }
        }
    }

    func refresh() async { load() }

    // MARK: - Response

    private func handleResponse(_ response: AnyObject) {
        if let errorMessage = response as? String, errorMessage.hasPrefix("Error:") {
            finish(with: [])
            hostViewController?.view.showToast(message: errorMessage.replacingOccurrences(of: "Error: ", with: ""))
            return
        }

        guard let json = response as? [String: Any],
              let data = try? JSONSerialization.data(withJSONObject: json),
              let decoded = try? JSONDecoder().decode(WearableDataRangeResponse.self, from: data) else {
            finish(with: [])
            hostViewController?.view.showToast(message: "An Unknown error occured. Please check with Admin".localized)
            return
        }

        guard decoded.statusResponse.responseCode == 200 else {
            finish(with: [])
            hostViewController?.view.showToast(message: decoded.statusResponse.responseMessage)
            return
        }

        finish(with: decoded.data ?? [])
    }

    /// Always renders a card per date in the range — days the backend skipped show
    /// their header only, which is the agreed empty state.
    private func finish(with payload: [WearableData]) {
        isLoading = false
        hasLoaded = true
        hostViewController?.view.hideToastActivity()
        days = WearableRangeDayBuilder.days(from: startDate, to: endDate, payload: payload)
    }

    func openBack() {
        if let onClose {
            onClose()
            return
        }
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    // MARK: - Formatters

    private static let apiFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private static let headerFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()
}

#if DEBUG
@available(iOS 16.0, *)
extension HealthDataRangeViewModel {

    /// Preview-only model with one populated day and two empty ones.
    static func previewModel() -> HealthDataRangeViewModel {
        let viewModel = HealthDataRangeViewModel(startDate: Date(), endDate: Date())
        viewModel.days = [
            WearableRangeDayPresentation(id: "2026-07-01", dateHeader: "1 Jul 2026", categories: []),
            WearableRangeDayPresentation(
                id: "2026-07-08", dateHeader: "8 Jul 2026",
                categories: [
                    WearableRangeCategoryPresentation(
                        id: "vitals", title: "Vitals", iconName: "heart.fill",
                        rows: [
                            WearableRangeValueRow(id: "heart_rate", title: "Heart Rate", valueText: "80 bpm"),
                            WearableRangeValueRow(id: "spo2", title: "SpO2", valueText: "99 %"),
                        ]),
                    WearableRangeCategoryPresentation(
                        id: "activity", title: "Activity", iconName: "figure.walk",
                        rows: [
                            WearableRangeValueRow(id: "steps", title: "Steps", valueText: "7,497"),
                        ]),
                ]),
            WearableRangeDayPresentation(id: "2026-07-09", dateHeader: "9 Jul 2026", categories: []),
        ]
        viewModel.hasLoaded = true
        return viewModel
    }
}
#endif
