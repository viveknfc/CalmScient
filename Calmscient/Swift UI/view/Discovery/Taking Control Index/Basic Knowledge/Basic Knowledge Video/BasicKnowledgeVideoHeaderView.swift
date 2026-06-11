//
//  BasicKnowledgeVideoHeaderView.swift
//  Calmscient
//
//  Question title, brand label, and subtitle above the brain video player.
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct BasicKnowledgeVideoHeaderView: View {

    let questionTitle: String
    let brandTitle: String
    let subtitle: String

    private let headlineColor = Color(red: 0.431, green: 0.419, blue: 0.701)
    private let brandColor = Color(red: 0.429, green: 0.420, blue: 0.682)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(questionTitle)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 16))
                .foregroundStyle(headlineColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            Text(brandTitle)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                .foregroundStyle(brandColor)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(subtitle)
                .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                .foregroundStyle(Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 8)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Brain video header") {
    BasicKnowledgeVideoHeaderView(
        questionTitle: "DRINKING_CONTROL_Consequence_What_Happens_To_Your_Brain_When_You_Drink".localized,
        brandTitle: "BASIC_KNOWLEDGE_Tipsy_Truth".localized,
        subtitle: "DRINKING_CONTROL_Video_Sub_Header".localized
    )
    .padding()
}
#endif
