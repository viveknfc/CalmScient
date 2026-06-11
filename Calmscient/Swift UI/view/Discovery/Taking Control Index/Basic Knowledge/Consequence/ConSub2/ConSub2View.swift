//
//  ConSub2View.swift
//  Calmscient
//
//  SwiftUI Alcohol-related mental dysfunction screen (parity with legacy `ConSub2VC`).
//
//  Vivek
//  25 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ConSub2View: View {

    @ObservedObject var viewModel: ConSub2ViewModel

    private let pageBackground = Color("AppBackGroundColor")

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    BasicStandardDrinkHeaderView(title: viewModel.content.headerTitle)

                    ModerationIntroTextView(text: viewModel.content.introText)

                    ConSub2NumberedListView(items: viewModel.content.numberedItems)
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
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("ConSub2 mental dysfunction") {
    let viewModel = ConSub2ViewModel()
    viewModel.applyPreviewState()
    return ConSub2View(viewModel: viewModel)
}
#endif
