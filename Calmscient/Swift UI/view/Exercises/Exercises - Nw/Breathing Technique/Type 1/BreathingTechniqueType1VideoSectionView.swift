//
//  BreathingTechniqueType1VideoSectionView.swift
//  Calmscient
//
//  Type-alias style wrapper around `BreathingExerciseVideoSectionView` for 4-7-8 breathing.
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct BreathingTechniqueType1VideoSectionView: View {

    @ObservedObject var viewModel: BreathingTechniqueType1ViewModel

    var body: some View {
        BreathingExerciseVideoSectionView(viewModel: viewModel)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Video section") {
    let viewModel = BreathingTechniqueType1ViewModel()
    viewModel.applyPreviewState()
    return BreathingTechniqueType1VideoSectionView(viewModel: viewModel)
        .padding()
}
#endif
