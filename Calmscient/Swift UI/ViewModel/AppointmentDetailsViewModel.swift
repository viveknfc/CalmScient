//
//  AppointmentDetailsViewModel.swift
//  Calmscient
//
//  State and navigation parity with legacy `AppointmentDetailsVC` (display-only; no API on this screen).
//
//  Vivek
//  15 May 2026
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class AppointmentDetailsViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var presentation: AppointmentDetailPresentation?
    @Published private(set) var navigationTitle: String = ""
    @Published private(set) var dateTimeLabel: String = ""
    @Published private(set) var contactLabel: String = ""
    @Published private(set) var addressLabel: String = ""
    @Published private(set) var appointmentDetailLabel: String = ""

    private let medicalAppointment: MedicalAppointmentDetailsByDate

    init(medicalAppointment: MedicalAppointmentDetailsByDate) {
        self.medicalAppointment = medicalAppointment
    }

    func onHostWillAppear() {
        navigationTitle = AppHelper.getLocalizeString(str: "Appointment Details")
        dateTimeLabel = AppHelper.getLocalizeString(str: "Date and Time")
        contactLabel = AppHelper.getLocalizeString(str: "Contact")
        addressLabel = AppHelper.getLocalizeString(str: "Address")
        appointmentDetailLabel = AppHelper.getLocalizeString(str: "Appointment Detail")
        presentation = AppointmentDetailPresentation.build(from: medicalAppointment)
    }

    func openBack() {
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    func openAddressOnMap() {
        guard let address = presentation?.address,
              !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "http://maps.apple.com/?q=\(encoded)") else {
            return
        }
        UIApplication.shared.open(url)
    }
}
