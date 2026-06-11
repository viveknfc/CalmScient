//
//  USGuideLineForDrinkingView.swift
//  Calmscient
//
//  SwiftUI U.S. drinking guidelines screen (parity with legacy `USGuideLineForDrinkingVC`).
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct USGuideLineForDrinkingView: View {

    @ObservedObject var viewModel: USGuideLineForDrinkingViewModel

    private let pageBackground = Color("AppBackGroundColor")

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(viewModel.sections) { section in
                        USGuideLineForDrinkingSectionView(section: section)
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 88)
            }

            BasicKnowledgeCompleteButtonView(
                title: viewModel.completeButtonTitle,
                onTap: viewModel.completeTapped
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(pageBackground.ignoresSafeArea())
        .overlay {
            if viewModel.isCompleting {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("U.S. guidelines screen") {
    let viewModel = USGuideLineForDrinkingViewModel()
    viewModel.applyPreviewState()
    return USGuideLineForDrinkingView(viewModel: viewModel)
}
#endif
