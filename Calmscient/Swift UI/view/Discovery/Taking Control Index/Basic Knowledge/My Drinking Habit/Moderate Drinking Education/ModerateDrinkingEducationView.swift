//
//  ModerateDrinkingEducationView.swift
//  Calmscient
//
//  SwiftUI moderate-drinking education screens (parity with legacy moderate VCs).
//
//  Vivek
//  25 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ModerateDrinkingEducationView: View {

    @ObservedObject var viewModel: ModerateDrinkingEducationViewModel

    private let pageBackground = Color("AppBackGroundColor")

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    BasicStandardDrinkHeaderView(title: viewModel.content.headerTitle)
                        .padding(.bottom, 20)

                    ForEach(Array(viewModel.content.bodyBlocks.enumerated()), id: \.offset) { index, block in
                        ModerateDrinkingEducationBodyBlockView(block: block)
                            .padding(.bottom, index < viewModel.content.bodyBlocks.count - 1 ? 10 : 0)
                    }
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
#Preview("Moderate drinking screen") {
    let viewModel = ModerateDrinkingEducationViewModel()
    viewModel.configure(variant: .moderateDrinking, sectionId: 6)
    viewModel.applyPreviewState()
    return ModerateDrinkingEducationView(viewModel: viewModel)
}

@available(iOS 16.0, *)
#Preview("Moderate everyday screen") {
    let viewModel = ModerateDrinkingEducationViewModel()
    viewModel.configure(variant: .moderateEveryday, sectionId: 6)
    viewModel.applyPreviewState()
    return ModerateDrinkingEducationView(viewModel: viewModel)
}

@available(iOS 16.0, *)
#Preview("Social weekend binge screen") {
    let viewModel = ModerateDrinkingEducationViewModel()
    viewModel.configure(variant: .socialWeekendBinge, sectionId: 6)
    viewModel.applyPreviewState()
    return ModerateDrinkingEducationView(viewModel: viewModel)
}

@available(iOS 16.0, *)
#Preview("Problematic drinking screen") {
    let viewModel = ModerateDrinkingEducationViewModel()
    viewModel.configure(variant: .problematicDrinking, sectionId: 6)
    viewModel.applyPreviewState()
    return ModerateDrinkingEducationView(viewModel: viewModel)
}
#endif
