//
//  ScreeningResultReminderBannerView.swift
//  Calmscient
//
//  Date/time and reminder row for screening results header.
//
//  Vivek
//  15 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ScreeningResultReminderBannerView: View {

    let testDateText: String
    let testTimeText: String
    let remindMeTitle: String
    let remindOptionTitle: String

    var body: some View {
        HStack(spacing: 0) {
            dateTimeSection
            reminderSection
        }
        .frame(maxWidth: .infinity)
        .frame(height: 90)
        .background(Color("AppViewTextColor"))
    }

    private var dateTimeSection: some View {
        HStack(alignment: .center, spacing: 10) {
            Image("clock")
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: -2) {
                Text(testDateText)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 16))
                    .foregroundStyle(Color("AppointmentsTextColor"))

                Text(testTimeText)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                    .foregroundStyle(Color("AppLightTextColor"))
            }
            .padding(.top, 6)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 12)
    }

    private var reminderSection: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .trailing, spacing: -2) {
                Text(remindMeTitle)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                    .foregroundStyle(Color("AppLightTextColor"))

                Text(remindOptionTitle)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 16))
                    .foregroundStyle(Color("MedicationsCellSubtitleColor"))
            }
            .padding(.top, 6)
            .padding(.bottom, 12)

            ZStack(alignment: .topTrailing) {
                Image("bell")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing, 12)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Reminder banner") {
    ScreeningResultReminderBannerView(
        testDateText: "05/15/2026",
        testTimeText: "5:52 PM",
        remindMeTitle: "Remind me",
        remindOptionTitle: "Weekly"
    )
}
#endif
