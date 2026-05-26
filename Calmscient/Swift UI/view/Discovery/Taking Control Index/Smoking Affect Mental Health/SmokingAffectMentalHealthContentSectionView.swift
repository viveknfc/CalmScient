//
//  SmokingAffectMentalHealthContentSectionView.swift
//  Calmscient
//
//  Scrollable education content for the smoking and mental health screen.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct SmokingAffectMentalHealthContentSectionView: View {

    let content: SmokingEducationContentPresentation

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            BasicStandardDrinkHeaderView(title: content.headerTitle)
                .padding(.bottom, 20)

            ForEach(Array(content.bodyParagraphs.enumerated()), id: \.offset) { index, paragraph in
                HoldYourLiquorBodyParagraphView(text: paragraph)
                    .padding(.bottom, index < content.bodyParagraphs.count - 1 ? 10 : 0)
            }
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Smoking mental health content") {
    SmokingAffectMentalHealthContentSectionView(
        content: SmokingAffectMentalHealthPresentation.buildLocalizedContent()
    )
    .padding(.horizontal, 20)
}
#endif
