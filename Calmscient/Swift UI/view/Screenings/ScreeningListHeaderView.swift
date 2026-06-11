//
//  ScreeningListHeaderView.swift
//  Calmscient
//
//  Intro copy above the screenings list.
//
//  Vivek
//  15 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ScreeningListHeaderView: View {

    let title: String
    let subtitle: String

    private let titleColor = LoginDesignSystem.ColorName.titleGray
    private let subtitleColor = Color(red: 0.33, green: 0.33, blue: 0.33)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(LoginDesignSystem.Typography.lexendMedium(size: 16))
                .foregroundStyle(titleColor)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Text(subtitle)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                .foregroundStyle(subtitleColor)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Screening list header") {
    ScreeningListHeaderView(
        title: "Please complete all of the following screenings",
        subtitle: "Even if you feel they may not apply to you. These assessments helps us better understand your overall wellbeing."
    )
    .padding()
}
#endif
