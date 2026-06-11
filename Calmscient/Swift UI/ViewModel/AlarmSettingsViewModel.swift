//
//  AlarmSettingsViewModel.swift
//  Calmscient
//
//  Alarm lead-time sheet (parity with legacy `settingsAlarmVC`).
//
//  Vivek
//  14 May 2026
//
import Foundation
import SwiftUI
import UIKit

@MainActor
final class AlarmSettingsViewModel: ObservableObject {

    static let allowedMinutes = [5, 10, 15, 20, 25, 30]

    weak var hostViewController: UIViewController?
    weak var delegate: SettingsAlarmDelegate?

    @Published var selectedMinutes: Int?
    @Published private(set) var isSubmitting: Bool = false

    private var anchorView: UIView? { hostViewController?.view }

    init(initialAlarmMinutes: Int) {
        if Self.allowedMinutes.contains(initialAlarmMinutes) {
            selectedMinutes = initialAlarmMinutes
        } else {
            selectedMinutes = nil
        }
    }

    func rowLabel(minutes: Int) -> String {
        "\(minutes) \("alarm_time_unit_min".localized)"
    }

    func select(minutes: Int) {
        selectedMinutes = minutes
        UserDefaults.standard.set(minutes, forKey: "alarmPriorMinutes")
    }

    func cancel() {
        NotificationCenter.default.post(name: Notification.Name("RemoveDimmingView"), object: nil)
        hostViewController?.dismiss(animated: true)
    }

    func confirm() {
        guard let minutes = selectedMinutes else {
            hostViewController?.showGeneralAlert(
                image: UIImage(named: "InfoIcon"),
                imageSize: CGSize(width: 60, height: 60),
                title: "Please select a time interval before proceeding.".localized,
                okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                okAction: {},
                dismissAction: {},
                showDismissButton: true
            )
            return
        }

        guard let userInfo = ApplicationSharedInfo.shared.loginResponse,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }

        isSubmitting = true
        anchorView?.showToastActivity()

        let params: [String: Any] = [
            "patientId": userInfo.patientID,
            "alarmDuration": minutes,
            "emailId": userInfo.email,
        ]

        APIService.alarmSettingsAPICalling(
            hostViewController,
            params: params,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleAlarmAPIResponse(response, savedMinutes: minutes)
            }
        }
    }

    private func handleAlarmAPIResponse(_ response: AnyObject, savedMinutes: Int) {
        isSubmitting = false
        anchorView?.hideToastActivity()

        if let responseDict = response as? [String: Any],
           let responseMessage = responseDict["responseMessage"] as? String {
            hostViewController?.showSuccessAlert(successContent: responseMessage, centreImage: nil, okButtonAction: { [weak self] in
                guard let self else { return }
                self.delegate?.didUpdateAlarmValue(savedMinutes)
                UserDefaults.standard.set(savedMinutes, forKey: "alarmPriorMinutes")
                NotificationCenter.default.post(name: Notification.Name("RemoveDimmingView"), object: nil)
                self.hostViewController?.dismiss(animated: true)
            })
        } else if response is String {
            print("Response received from alarm setting api calling is", response)
        } else {
            print("Unsupported response type:", type(of: response))
        }
    }
}
