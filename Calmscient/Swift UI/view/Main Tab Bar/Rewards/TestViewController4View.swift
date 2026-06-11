//
//  TestViewController4View.swift
//  Calmscient
//
//  SwiftUI rewards tab content.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TestViewController4View: View {
    @ObservedObject var viewModel: TestViewController4ViewModel

    var body: some View {
        VStack {
            Spacer()
            TestViewController4RewardImageView(imageName: viewModel.rewardImageName)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Rewards view") {
    let vm = TestViewController4ViewModel()
    vm.applyPreviewState()
    return TestViewController4View(viewModel: vm)
}
#endif
