//
//  QuitSymptomModalTimelineBlockView.swift
//  Calmscient
//
//  Vertical timeline list of connected cards for symptom modals.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct QuitSymptomModalTimelineBlockView: View {

    let steps: [String]

    var body: some View {
        QuitSymptomModalTimelineSectionView(steps: steps)
            .padding(.top, 4)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Quit symptom timeline block") {
    QuitSymptomModalTimelineBlockView(steps: [
        "Put on a new patch each morning to get a steady level of nicotine.",
        "Use a fast-acting nicotine medicine like lozenges or gum to quickly combat cravings",
        "You can control how often you use the fast-acting medicine, so you won't get more nicotine than you want.",
    ])
    .padding()
}
#endif
