//
//  HealthMetricDetailViewModel.swift
//  Calmscient
//
//  Created by NFC Solutions on 11/08/26.
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class HealthMetricDetailViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    // MARK: - SwiftUI navigation
    //
    // Set by `HomeTabView` when this screen is shown inside the Home `NavigationStack`.
    // While nil, every call below falls through to the existing UIKit push/pop, which is
    // what the still-UIKit Discovery tab uses when it pushes into these screens.
    var onOpenRoute: ((HomeRoute) -> Void)?
    var onClose: (() -> Void)?
    var onCloseToRoot: (() -> Void)?

    let metric: HealthMetric

    @Published var fromDate: Date = Date()
    @Published var toDate: Date = Date()
    @Published private(set) var rows: [HealthMetricDayValue] = []
    @Published private(set) var isLoading = false

    var screenTitle: String { metric.titleKey.localized }

    /// Display text for the reused date fields (same format as Weekly Summary).
    var fromDateText: String { fromDate.dateToString(format: "MM/dd/yyyy") }
    var toDateText: String { toDate.dateToString(format: "MM/dd/yyyy") }

    /// Shared app-wide bottom sheet calendar (same one used by Weekly Summary graphs).
    private let datePickerPresenter = BottomSheetDatePickerPresenter()

    init(metric: HealthMetric) {
        self.metric = metric
        let today = Date()
        self.fromDate = today
        self.toDate = today
    }

    private var patientId: Int? { ApplicationSharedInfo.shared.loginResponse?.patientID }
    private var accessToken: String? { ApplicationSharedInfo.shared.tokenResponse?.accessToken }

    // MARK: - Date pickers (reuses the shared BottomSheetDatePickerPresenter)

    func presentFromDatePicker() {
        guard let host = hostViewController else { return }
        datePickerPresenter.present(
            from: host,
            configuration: BottomSheetDatePickerConfiguration(
                pickerMode: .date,
                maximumDate: toDate,          // From can't be after To
                initialDate: fromDate
            )
        ) { [weak self] selectedDate, _ in
            self?.fromDate = selectedDate
        }
    }

    func presentToDatePicker() {
        guard let host = hostViewController else { return }
        datePickerPresenter.present(
            from: host,
            configuration: BottomSheetDatePickerConfiguration(
                pickerMode: .date,
                minimumDate: fromDate,        // To can't be before From
                maximumDate: Date(),          // and not in the future
                initialDate: toDate
            )
        ) { [weak self] selectedDate, _ in
            self?.toDate = selectedDate
        }
    }

    // MARK: - Default load (current date, single-day API)

    func loadCurrentDate() {
        let today = Date()
        fromDate = today
        toDate = today
        loadSingleDate(today)
    }

    private func loadSingleDate(_ date: Date) {
        guard let patientId, let token = accessToken else { return }

        isLoading = true
        hostViewController?.view.showToastActivity()

        let dateString = date.dateToString(format: "yyyy-MM-dd")
        let params: [String: Any] = [
            "patientId": patientId,
            "date": dateString
        ]

        APIService.getWearableDataAPICalling(
            hostViewController,
            params: params,
            accessToken: token
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleSingleResponse(response, fallbackDate: dateString)
            }
        }
    }

    // MARK: - Go button (date range API)

    func loadRange() {
        guard fromDate <= toDate else {
            hostViewController?.view.showToast(message: "From date must be on or before To date.".localized)
            return
        }
        guard let patientId, let token = accessToken else { return }

        isLoading = true
        hostViewController?.view.showToastActivity()

        let start = fromDate.dateToString(format: "yyyy-MM-dd")
        let end = toDate.dateToString(format: "yyyy-MM-dd")
        let params: [String: Any] = [
            "patientId": patientId,
            "startDate": start,
            "endDate": end
        ]

        APIService.getWearableDataRangeAPICalling(
            hostViewController,
            params: params,
            accessToken: token
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleRangeResponse(response)
            }
        }
    }

    // MARK: - Response handling

    private func handleSingleResponse(_ response: AnyObject, fallbackDate: String) {
        isLoading = false
        hostViewController?.view.hideToastActivity()

        if let errorMessage = response as? String, errorMessage.hasPrefix("Error:") {
            rows = []
            hostViewController?.view.showToast(message: errorMessage.replacingOccurrences(of: "Error: ", with: ""))
            return
        }

        guard let json = response as? [String: Any],
              let data = try? JSONSerialization.data(withJSONObject: json),
              let decoded = try? JSONDecoder().decode(WearableDataResponse.self, from: data) else {
            rows = []
            hostViewController?.view.showToast(message: "An Unknown error occured. Please check with Admin".localized)
            return
        }

        guard decoded.statusResponse.responseCode == 200 else {
            rows = []
            hostViewController?.view.showToast(message: decoded.statusResponse.responseMessage)
            return
        }

        rows = [ makeRow(from: decoded.data, fallbackDate: fallbackDate) ]
    }

    private func handleRangeResponse(_ response: AnyObject) {
        isLoading = false
        hostViewController?.view.hideToastActivity()

        if let errorMessage = response as? String, errorMessage.hasPrefix("Error:") {
            rows = []
            hostViewController?.view.showToast(message: errorMessage.replacingOccurrences(of: "Error: ", with: ""))
            return
        }

        guard let json = response as? [String: Any],
              let data = try? JSONSerialization.data(withJSONObject: json),
              let decoded = try? JSONDecoder().decode(WearableDataRangeResponse.self, from: data) else {
            rows = []
            hostViewController?.view.showToast(message: "An Unknown error occured. Please check with Admin".localized)
            return
        }

        guard decoded.statusResponse.responseCode == 200 else {
            rows = []
            hostViewController?.view.showToast(message: decoded.statusResponse.responseMessage)
            return
        }

        let days = decoded.data ?? []
        // Each date becomes a header; newest first.
        rows = days
            .sorted { ($0.date ?? "") > ($1.date ?? "") }
            .map { makeRow(from: $0, fallbackDate: $0.date ?? "") }

        if rows.isEmpty {
            hostViewController?.view.showToast(message: "No data for the selected range.".localized)
        }
    }

    private func makeRow(from data: WearableData?, fallbackDate: String) -> HealthMetricDayValue {
        let dateString = data?.date ?? fallbackDate
        return HealthMetricDayValue(
            dateHeader: Self.headerLabel(from: dateString),
            valueText: WearableMetricValueMapper.value(for: metric, in: data))
    }

    /// "2026-07-19" -> "19 Jul 2026" (falls back to the raw string).
    private static func headerLabel(from apiDate: String) -> String {
        let input = DateFormatter()
        input.dateFormat = "yyyy-MM-dd"
        input.timeZone = TimeZone(identifier: Calendar.current.timeZone.identifier)
        guard let date = input.date(from: apiDate) else { return apiDate }

        let output = DateFormatter()
        output.dateFormat = "dd MMM yyyy"
        output.timeZone = TimeZone(identifier: Calendar.current.timeZone.identifier)
        return output.string(from: date)
    }

    func openBack() {
        if let onClose {
            onClose()
            return
        }
        hostViewController?.navigationController?.popViewController(animated: true)
    }
}

#if DEBUG
@available(iOS 16.0, *)
extension HealthMetricDetailViewModel {

    /// Preview-only model with dummy dated rows. Not used in release builds.
    static func previewModel(metricId: String = "heart_rate") -> HealthMetricDetailViewModel {
        let metric = HealthMetric.metric(for: metricId)!
        let vm = HealthMetricDetailViewModel(metric: metric)
        vm.rows = [
            HealthMetricDayValue(dateHeader: "19 Jul 2026", valueText: "72 bpm"),
            HealthMetricDayValue(dateHeader: "18 Jul 2026", valueText: "75 bpm"),
            HealthMetricDayValue(dateHeader: "17 Jul 2026", valueText: "--"),
        ]
        return vm
    }
}
#endif
