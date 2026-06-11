//
//  ConSub3View.swift
//  Calmscient
//
//  SwiftUI Alcohol-related blackouts screen (parity with legacy `ConSub3VC`).
//
//  Vivek
//  25 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ConSub3View: View {

    @ObservedObject var viewModel: ConSub3ViewModel

    private let pageBackground = Color("AppBackGroundColor")

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    BasicStandardDrinkHeaderView(title: viewModel.content.headerTitle)

                    ModerationIntroTextView(text: viewModel.content.bodyText)
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
#Preview("ConSub3 blackouts") {
    let viewModel = ConSub3ViewModel()
    viewModel.applyPreviewState()
    return ConSub3View(viewModel: viewModel)
}
#endif
