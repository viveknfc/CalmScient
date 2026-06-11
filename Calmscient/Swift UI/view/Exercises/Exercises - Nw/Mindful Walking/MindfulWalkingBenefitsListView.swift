//
//  MindfulWalkingBenefitsListView.swift
//  Calmscient
//
//  Numbered benefits list.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MindfulWalkingBenefitsListView: View {

    let benefits: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(benefits.enumerated()), id: \.offset) { idx, benefit in
                MindfulWalkingBenefitRowView(index: idx + 1, text: benefit)
            }
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Mindful walking benefits") {
    MindfulWalkingBenefitsListView(
        benefits: [
            "Stress Reduction: ...",
            "Emotional Regulation: ...",
        ]
    )
    .padding()
}
#endif
