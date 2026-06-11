//
//  NextAppointmentRowPresentation.swift
//  Calmscient
//
//  List row models for next appointments (parity with legacy table data).
//
//  Vivek
//  15 May 2026
//

import Foundation

@available(iOS 16.0, *)
enum NextAppointmentRowPresentation: Identifiable {
    case empty(dateLabel: String)
    case appointment(MedicalAppointmentDetailsByDate, showDateHeader: Bool)

    var id: String {
        switch self {
        case .empty(let dateLabel):
            return "empty-\(dateLabel)"
        case .appointment(let details, let showDateHeader):
            return "appt-\(details.appointmentDetails.appointmentId)-\(showDateHeader)"
        }
    }
}
