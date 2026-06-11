//
//  TestViewController4RewardImageView.swift
//  Calmscient
//
//  Reward image section used by rewards tab.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TestViewController4RewardImageView: View {
    let imageName: String

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 300, height: 200)
            .accessibilityHidden(true)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Rewards image") {
    TestViewController4RewardImageView(imageName: "rewardImg")
}
#endif
