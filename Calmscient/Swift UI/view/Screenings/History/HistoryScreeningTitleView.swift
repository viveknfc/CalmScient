//
//  HistoryScreeningTitleView.swift
//  Calmscient
//
//  Screening type header above history cards (e.g. PHQ-9).
//
//  Vivek
//  15 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct HistoryScreeningTitleView: View {

    let title: String

    private let titleColor = LoginDesignSystem.ColorName.titleGray

    var body: some View {
        Text(title)
            .font(LoginDesignSystem.Typography.lexendMedium(size: 16))
            .foregroundStyle(titleColor)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("History screening title") {
    HistoryScreeningTitleView(title: "PHQ-9")
        .padding()
}
#endif
