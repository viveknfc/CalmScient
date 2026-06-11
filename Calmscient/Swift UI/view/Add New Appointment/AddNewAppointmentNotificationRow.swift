//
//  AddNewAppointmentNotificationRow.swift
//  Calmscient
//
//  Alert notification checkbox row.
//
//  Vivek
//  15 May 2026
//

import SwiftUI

struct AddNewAppointmentNotificationRow: View {
    let isEnabled: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(isEnabled ? "CellSelectionImage" : "cellUnselectedImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)

            Text(AppHelper.getLocalizeString(str: "Send an alert notification"))
                .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                .foregroundStyle(LoginDesignSystem.ColorName.navy)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)
        }
    }
}

#if DEBUG
#Preview("Notification on") {
    AddNewAppointmentNotificationRow(isEnabled: true, onToggle: {})
        .padding()
        .background(Color("AppBackGroundColor"))
}

#Preview("Notification off") {
    AddNewAppointmentNotificationRow(isEnabled: false, onToggle: {})
        .padding()
        .background(Color("AppBackGroundColor"))
}
#endif
