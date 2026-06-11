//
//  AddNewAppointmentDateTimeRow.swift
//  Calmscient
//
//  Tappable date or time row that opens the bottom-sheet picker.
//
//  Vivek
//  15 May 2026
//

import SwiftUI

struct AddNewAppointmentDateTimeRow: View {
    let title: String
    let value: String
    let systemImageName: String
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AddEditMedicationRequiredTitleView(title: title)

            Button(action: onTap) {
                HStack {
                    Text(value.isEmpty ? " " : value)
                        .font(LoginDesignSystem.Typography.lexendLight(size: 16))
                        .foregroundStyle(LoginDesignSystem.ColorName.navy)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: systemImageName)
                        .foregroundStyle(LoginDesignSystem.ColorName.primaryGradientTop)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color("lightF2F2F2Color"))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color("light6E6BB3Color"), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

#if DEBUG
#Preview("Date row") {
    AddNewAppointmentDateTimeRow(
        title: "Date",
        value: "05/15/2026",
        systemImageName: "calendar",
        onTap: {}
    )
    .padding()
    .background(Color("AppBackGroundColor"))
}

#Preview("Time row empty") {
    AddNewAppointmentDateTimeRow(
        title: "Time",
        value: "",
        systemImageName: "clock",
        onTap: {}
    )
    .padding()
    .background(Color("AppBackGroundColor"))
}
#endif
