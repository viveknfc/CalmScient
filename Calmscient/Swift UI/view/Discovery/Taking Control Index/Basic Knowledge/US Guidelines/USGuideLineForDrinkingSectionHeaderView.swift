//
//  USGuideLineForDrinkingSectionHeaderView.swift
//  Calmscient
//
//  Section title and subtitle for U.S. drinking guidelines content.
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct USGuideLineForDrinkingSectionHeaderView: View {

    let section: USDrinkingGuidelineSectionPresentation

    private let titlePurple = Color("barColor1")
    private let accentPurple = Color(red: 0.427, green: 0.419, blue: 0.682)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            titleRow

            if let subtitle = section.subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                    .foregroundStyle(Color.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder
    private var titleRow: some View {
        if let title = section.title, !title.isEmpty {
            Text(title)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 16))
                .foregroundStyle(titlePurple)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        } else if let prefix = section.titlePrefix, let accent = section.titleAccent {
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text(prefix)
                    .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                    .foregroundStyle(Color.primary)

                Text(accent)
                    .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                    .foregroundStyle(accentPurple)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Section header — full title") {
    USGuideLineForDrinkingSectionHeaderView(
        section: USDrinkingGuidelineSectionPresentation.previewSections()[0]
    )
    .padding(.horizontal, 20)
}

@available(iOS 16.0, *)
#Preview("Section header — split title") {
    USGuideLineForDrinkingSectionHeaderView(
        section: USDrinkingGuidelineSectionPresentation.previewSections()[1]
    )
    .padding(.horizontal, 20)
}
#endif
