//
//  ModerationView.swift
//  Calmscient
//
//  SwiftUI moderation education screen (parity with legacy `Moderation`).
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ModerationView: View {

    @ObservedObject var viewModel: ModerationViewModel

    private let pageBackground = Color("AppBackGroundColor")

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    BasicStandardDrinkHeaderView(title: viewModel.content.headerTitle)

                    ModerationIntroTextView(text: viewModel.content.introText)

                    ModerationBulletListView(items: viewModel.content.bulletItems)

                    ModerationBodyTextView(bodyText: viewModel.content.bodyAttributedText)
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
#Preview("Moderation screen") {
    let viewModel = ModerationViewModel()
    viewModel.applyPreviewState()
    return ModerationView(viewModel: viewModel)
}
#endif
