//
//  ConSub4View.swift
//  Calmscient
//
//  SwiftUI Health problems screen (parity with legacy `ConSub4VC`).
//
//  Vivek
//  25 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ConSub4View: View {

    @ObservedObject var viewModel: ConSub4ViewModel

    private let pageBackground = Color("AppBackGroundColor")

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    BasicStandardDrinkHeaderView(title: viewModel.content.headerTitle)

                    ModerationIntroTextView(text: viewModel.content.introText)

                    ModerationBulletListView(items: viewModel.content.bulletItems)
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
#Preview("ConSub4 health problems") {
    let viewModel = ConSub4ViewModel()
    viewModel.applyPreviewState()
    return ConSub4View(viewModel: viewModel)
}
#endif
