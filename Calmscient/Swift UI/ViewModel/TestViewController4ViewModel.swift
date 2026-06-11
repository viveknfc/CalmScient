//
//  TestViewController4ViewModel.swift
//  Calmscient
//
//  View state for Rewards tab content.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
@MainActor
final class TestViewController4ViewModel: ObservableObject {
    @Published private(set) var rewardImageName = TestViewController4Presentation.rewardImageName

    #if DEBUG
    func applyPreviewState() {
        rewardImageName = TestViewController4Presentation.rewardImageName
    }
    #endif
}
