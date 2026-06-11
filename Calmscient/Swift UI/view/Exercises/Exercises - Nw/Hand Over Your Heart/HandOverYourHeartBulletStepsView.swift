//
//  HandOverYourHeartBulletStepsView.swift
//  Calmscient
//
//  Bullet list for HOW TO DO IT instructions.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct HandOverYourHeartBulletStepsView: View {

    let steps: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(steps.enumerated()), id: \.offset) { _, step in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .font(LoginDesignSystem.Typography.lexendLight(size: 15))
                        .foregroundStyle(Color.primary)
                        .padding(.top, 2)

                    Text(step)
                        .font(LoginDesignSystem.Typography.lexendLight(size: 15))
                        .foregroundStyle(Color.primary)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Hand over heart bullets") {
    HandOverYourHeartBulletStepsView(
        steps: [
            "Rest the heel of your hand on your sternum around your heart area.",
            "Apply a steady, gentle, but firm pressure."
        ]
    )
}
#endif
