//
//  NextAppointmentsAppointmentCardView.swift
//  Calmscient
//
//  Single appointment row with optional date header and edit/delete menu.
//
//  Vivek
//  15 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct NextAppointmentsAppointmentCardView: View {

    let dateHeader: String?
    let providerName: String
    let onRowTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    private let titleDark = LoginDesignSystem.ColorName.titleGray

    var body: some View {
        VStack(alignment: .leading, spacing: showDateHeader ? 8 : 0) {
            if let dateHeader, showDateHeader {
                Text(dateHeader)
                    .font(LoginDesignSystem.Typography.lexendMedium(size: 14))
                    .foregroundStyle(titleDark)
            }

            HStack(spacing: 12) {
                Image("doctorWithSteth")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34, height: 34)

                Text(providerName)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 15))
                    .foregroundStyle(Color.black)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 8)

                Menu {
                    Button(action: onEdit) {
                        Label("Edit".localized, systemImage: "pencil")
                    }
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete".localized, systemImage: "trash")
                    }
                } label: {
                    Image("seperatorIcon")
                        .frame(width: 24, height: 24)
                }
                .menuStyle(.automatic)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardSurface)
            .contentShape(Rectangle())
            .onTapGesture(perform: onRowTap)
        }
    }

    private var showDateHeader: Bool {
        dateHeader != nil
    }

    private var cardSurface: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(Color("NextAppointmentsCellBackgroundColor"))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color("AppViewBorderColor"), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Appointment card with date") {
    NextAppointmentsAppointmentCardView(
        dateHeader: "05/15/2026",
        providerName: "Dr. Smith",
        onRowTap: {},
        onEdit: {},
        onDelete: {}
    )
    .padding()
}

@available(iOS 16.0, *)
#Preview("Appointment card without date") {
    NextAppointmentsAppointmentCardView(
        dateHeader: nil,
        providerName: "Dr. Smith",
        onRowTap: {},
        onEdit: {},
        onDelete: {}
    )
    .padding()
}
#endif
