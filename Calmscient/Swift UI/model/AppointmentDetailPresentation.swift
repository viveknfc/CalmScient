//
//  AppointmentDetailPresentation.swift
//  Calmscient
//
//  Display model for appointment details (built from `MedicalAppointmentDetailsByDate`).
//
//  Vivek
//  15 May 2026
//

import Foundation

struct AppointmentDetailPresentation: Equatable {
    let providerName: String
    let hospitalName: String
    let formattedDateTime: String
    let contact: String
    let address: String
    let appointmentDetail: String

    static func build(from appointment: MedicalAppointmentDetailsByDate) -> AppointmentDetailPresentation {
        let details = appointment.appointmentDetails
        return AppointmentDetailPresentation(
            providerName: details.providerName,
            hospitalName: details.hospitalName,
            formattedDateTime: Self.formatDateTime(details.dateAndTime),
            contact: details.contact ?? "",
            address: details.address ?? "",
            appointmentDetail: details.appointmentDetails
        )
    }

    private static func formatDateTime(_ raw: String) -> String {
        let input = DateFormatter()
        input.dateFormat = "yyyy-MM-dd HH:mm:ss"
        input.locale = Locale(identifier: "en_US_POSIX")
        input.timeZone = TimeZone.current

        guard let date = input.date(from: raw) else {
            return AppHelper.getLocalizeString(str: "Invalid Date")
        }

        let output = DateFormatter()
        output.dateFormat = "MM/dd/yyyy hh:mm a"
        output.locale = Locale(identifier: "en_US_POSIX")
        output.timeZone = TimeZone.current
        return output.string(from: date)
    }
}

#if DEBUG
extension AppointmentDetailPresentation {
    static let preview = AppointmentDetailPresentation(
        providerName: "Dr. Samuel Parker",
        hospitalName: "Hyderabad",
        formattedDateTime: "05/16/2026 02:30 PM",
        contact: "(804) 093 8172",
        address: "South Frederic Av 489",
        appointmentDetail: "Description"
    )
}
#endif
