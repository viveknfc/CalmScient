//
//  VapingView.swift
//  Calmscient
//
//  SwiftUI vaping education screen (parity with legacy `VapingViewController`).
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct VapingView: View {

    @ObservedObject var viewModel: VapingViewModel

    private let pageBackground = Color("AppBackGroundColor")

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    BasicStandardDrinkHeaderView(title: viewModel.content.headerTitle)
                        .padding(.bottom, 20)

                    ForEach(Array(viewModel.content.bodyParagraphs.enumerated()), id: \.offset) { _, paragraph in
                        HoldYourLiquorBodyParagraphView(text: paragraph)
                            .padding(.bottom, 10)
                    }

                    if let referenceURL = viewModel.content.referenceURL, !referenceURL.isEmpty {
                        VapingReferenceLinkView(
                            urlText: referenceURL,
                            onTap: viewModel.openReferenceURL
                        )
                        .padding(.top, 10)
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
#Preview("Vaping screen") {
    let viewModel = VapingViewModel()
    viewModel.applyPreviewState()
    return VapingView(viewModel: viewModel)
}
#endif
