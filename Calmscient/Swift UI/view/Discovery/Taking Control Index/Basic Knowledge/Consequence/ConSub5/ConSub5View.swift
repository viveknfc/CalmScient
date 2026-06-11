//
//  ConSub5View.swift
//  Calmscient
//
//  SwiftUI Alcohol use disorder (AUD) screen (parity with legacy `ConSub5VC`).
//
//  Vivek
//  25 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ConSub5View: View {

    @ObservedObject var viewModel: ConSub5ViewModel

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
#Preview("ConSub5 AUD") {
    let viewModel = ConSub5ViewModel()
    viewModel.applyPreviewState()
    return ConSub5View(viewModel: viewModel)
}
#endif
