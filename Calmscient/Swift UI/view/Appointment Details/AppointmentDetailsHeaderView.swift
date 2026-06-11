//
//  AppointmentDetailsHeaderView.swift
//  Calmscient
//
//  Provider header with doctor icon (parity with `AppointmentDetailsVC.storyboard`).
//
//  Vivek
//  15 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct AppointmentDetailsHeaderView: View {
    let providerName: String
    let hospitalName: String

    private let titleDark = Color(red: 0.259, green: 0.259, blue: 0.259)
    private let iconBackground = Color(red: 0.953, green: 0.953, blue: 0.953)
    private let contentBackground = Color(red: 0.984, green: 0.984, blue: 0.996)

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconBackground)
                    .frame(width: 60, height: 60)
                Image("doctorWithSteth")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 60)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(providerName)
                    .font(LoginDesignSystem.Typography.lexendMedium(size: 18))
                    .foregroundStyle(titleDark)
                    .lineLimit(2)

                Text(hospitalName)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                    .foregroundStyle(titleDark)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.leading, 34)
        .padding(.trailing, 8)
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, minHeight: 90, alignment: .leading)
        .background(contentBackground)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Appointment details header") {
    AppointmentDetailsHeaderView(
        providerName: "Dr. Samuel Parker",
        hospitalName: "Hyderabad"
    )
}
#endif
