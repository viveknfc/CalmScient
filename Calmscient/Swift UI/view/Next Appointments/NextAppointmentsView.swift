//
//  NextAppointmentsView.swift
//  Calmscient
//
//  SwiftUI next appointments list (parity with legacy `NextAppointmentsViewController`).
//
//  Vivek
//  15 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct NextAppointmentsView: View {

    @ObservedObject var viewModel: NextAppointmentsViewModel

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                MedicalCalendarHeaderView(provider: viewModel)

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(viewModel.rows) { row in
                            rowView(for: row)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 150)
                }
            }

            Button {
                viewModel.openAddAppointment()
            } label: {
                Image("AddButton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 14)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
        // Loading is shown by the app-wide toast activity indicator that the view model
        // drives (`showToastActivity` / `hideToastActivity`). A second SwiftUI
        // `ProgressView` overlay used to be stacked on top of it here, which made two
        // spinners appear at once.
    }

    @ViewBuilder
    private func rowView(for row: NextAppointmentRowPresentation) -> some View {
        switch row {
        case .empty(let dateLabel):
            NextAppointmentsEmptyCardView(dateLabel: dateLabel)

        case .appointment(let appointment, let showDateHeader):
            let dateText = appointment.appointmentDetails.dateAndTime.toFormattedDateString() ?? ""
            NextAppointmentsAppointmentCardView(
                dateHeader: showDateHeader ? dateText : nil,
                providerName: appointment.appointmentDetails.providerName,
                onRowTap: { viewModel.openAppointmentDetail(appointment) },
                onEdit: { viewModel.openEditAppointment(appointment) },
                onDelete: { viewModel.confirmDeleteAppointment(appointment) }
            )
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Next appointments screen") {
    NextAppointmentsView(viewModel: NextAppointmentsViewModel())
}
#endif
