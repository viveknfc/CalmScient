//
//  AppointmentDetailsView.swift
//  Calmscient
//
//  SwiftUI appointment details screen (parity with `AppointmentDetailsVC`).
//
//  Vivek
//  15 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct AppointmentDetailsView: View {

    @ObservedObject var viewModel: AppointmentDetailsViewModel

    private let sectionDivider = Color(red: 0.878, green: 0.878, blue: 0.878)
    private let contactPurple = Color(red: 0.431, green: 0.420, blue: 0.702)

    var body: some View {
        ScrollView {
            if let presentation = viewModel.presentation {
                VStack(spacing: 1) {
                    AppointmentDetailsHeaderView(
                        providerName: presentation.providerName,
                        hospitalName: presentation.hospitalName
                    )

                    AppointmentDetailsInfoRowView(
                        label: viewModel.dateTimeLabel,
                        value: presentation.formattedDateTime
                    )

                    AppointmentDetailsInfoRowView(
                        label: viewModel.contactLabel,
                        value: presentation.contact,
                        valueColor: contactPurple
                    )

                    AppointmentDetailsAddressRowView(
                        label: viewModel.addressLabel,
                        address: presentation.address,
                        onMapTap: { viewModel.openAddressOnMap() }
                    )

                    AppointmentDetailsInfoRowView(
                        label: viewModel.appointmentDetailLabel,
                        value: presentation.appointmentDetail
                    )
                }
                .background(sectionDivider)
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}

#if DEBUG
@available(iOS 16.0, *)
private enum AppointmentDetailsPreviewData {
    static let json = """
    {
      "hospitalName": "Central Park Hospital",
      "appointmentDetails": {
        "appointmentId": 1,
        "providerName": "Dr. Samuel Parker",
        "hospitalName": "Hyderabad",
        "dateAndTime": "2026-05-16 14:30:00",
        "contact": "(804) 093 8172",
        "address": "South Frederic Av 489",
        "appointmentDetails": "Description",
        "alert": 0
      }
    }
    """

    @MainActor static func makeViewModel() -> AppointmentDetailsViewModel {
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        guard let appointment = try? decoder.decode(MedicalAppointmentDetailsByDate.self, from: data) else {
            fatalError("Preview JSON decode failed")
        }
        let vm = AppointmentDetailsViewModel(medicalAppointment: appointment)
        vm.onHostWillAppear()
        return vm
    }
}

@available(iOS 16.0, *)
#Preview("Appointment details screen") {
    AppointmentDetailsView(viewModel: AppointmentDetailsPreviewData.makeViewModel())
}
#endif
