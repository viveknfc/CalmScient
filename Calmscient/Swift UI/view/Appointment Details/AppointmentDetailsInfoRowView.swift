//
//  AppointmentDetailsInfoRowView.swift
//  Calmscient
//
//  Label + value row for appointment detail sections.
//
//  Vivek
//  15 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct AppointmentDetailsInfoRowView: View {
    let label: String
    let value: String
    var valueColor: Color = Color(red: 0.259, green: 0.259, blue: 0.259)
    var valueFont: Font = LoginDesignSystem.Typography.lexendRegular(size: 18)

    private let labelGray = Color(red: 0.776, green: 0.776, blue: 0.784)

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(LoginDesignSystem.Typography.lexendLight(size: 15))
                .foregroundStyle(labelGray)

            Text(value)
                .font(valueFont)
                .foregroundStyle(valueColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.top, 22)
        .padding(.bottom, 22)
        .frame(maxWidth: .infinity, minHeight: 90, alignment: .topLeading)
        .background(Color.white)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Appointment details info row") {
    VStack(spacing: 0) {
        AppointmentDetailsInfoRowView(
            label: "Date and Time",
            value: "05/16/2026 02:30 PM"
        )
        AppointmentDetailsInfoRowView(
            label: "Contact",
            value: "(804) 093 8172",
            valueColor: Color(red: 0.431, green: 0.420, blue: 0.702)
        )
    }
}
#endif
