//
//  SmokingAffectMentalHealthView.swift
//  Calmscient
//
//  SwiftUI smoking and mental health education screen (parity with legacy `SmokingAffectMentalHealthVC`).
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct SmokingAffectMentalHealthView: View {

    @ObservedObject var viewModel: SmokingAffectMentalHealthViewModel

    private let pageBackground = Color("AppBackGroundColor")

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                SmokingAffectMentalHealthContentSectionView(content: viewModel.content)
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
#Preview("Smoking mental health screen") {
    let viewModel = SmokingAffectMentalHealthViewModel()
    viewModel.applyPreviewState()
    return SmokingAffectMentalHealthView(viewModel: viewModel)
}
#endif
