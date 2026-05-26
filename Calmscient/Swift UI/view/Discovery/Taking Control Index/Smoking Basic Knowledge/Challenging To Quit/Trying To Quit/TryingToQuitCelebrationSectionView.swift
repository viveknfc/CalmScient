//
//  TryingToQuitCelebrationSectionView.swift
//  Calmscient
//
//  Celebration milestones block on the trying-to-quit screen.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TryingToQuitCelebrationSectionView: View {

    let title: String
    let milestones: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HoldYourLiquorBodyParagraphView(text: title)
            ModerationBulletListView(items: milestones)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Trying to quit celebration") {
    TryingToQuitCelebrationSectionView(
        title: "trying_to_quit_celebrate_heading".localized,
        milestones: [
            "trying_to_quit_milestone_3_days".localized,
            "trying_to_quit_milestone_7_days".localized,
        ]
    )
    .padding(.horizontal, 20)
}
#endif
