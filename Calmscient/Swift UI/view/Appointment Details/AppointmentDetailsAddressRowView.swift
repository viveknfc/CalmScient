//
//  AppointmentDetailsAddressRowView.swift
//  Calmscient
//
//  Address row with map action (parity with `location_svg` in storyboard).
//
//  Vivek
//  15 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct AppointmentDetailsAddressRowView: View {
    let label: String
    let address: String
    let onMapTap: () -> Void

    private let labelGray = Color(red: 0.776, green: 0.776, blue: 0.784)
    private let titleDark = Color(red: 0.259, green: 0.259, blue: 0.259)

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(LoginDesignSystem.Typography.lexendLight(size: 15))
                    .foregroundStyle(labelGray)

                Text(address)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 18))
                    .foregroundStyle(titleDark)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button(action: onMapTap) {
                Image("location_svg")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.plain)
            .frame(width: 30, height: 30)
        }
        .padding(.leading, 16)
        .padding(.trailing, 20)
        .padding(.top, 22)
        .padding(.bottom, 22)
        .frame(maxWidth: .infinity, minHeight: 90, alignment: .topLeading)
        .background(Color.white)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Appointment details address row") {
    AppointmentDetailsAddressRowView(
        label: "Address",
        address: "South Frederic Av 489",
        onMapTap: {}
    )
}
#endif
