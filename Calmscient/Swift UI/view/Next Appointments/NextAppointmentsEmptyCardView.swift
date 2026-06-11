//
//  NextAppointmentsEmptyCardView.swift
//  Calmscient
//
//  Empty day card — "No appointments" (legacy `AppointmentsEmptyTableViewCell` empty state).
//
//  Vivek
//  15 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct NextAppointmentsEmptyCardView: View {

    let dateLabel: String

    private let titleDark = LoginDesignSystem.ColorName.titleGray

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(dateLabel)
                .font(LoginDesignSystem.Typography.lexendMedium(size: 14))
                .foregroundStyle(titleDark)

            HStack(spacing: 12) {
                Image("appointmentIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34, height: 34)

                Text("No appointments".localized)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 15))
                    .foregroundStyle(Color.black)

                Spacer(minLength: 0)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardSurface)
        }
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
#Preview("Empty appointment card") {
    NextAppointmentsEmptyCardView(dateLabel: "05/15/2026")
        .padding()
}
#endif
