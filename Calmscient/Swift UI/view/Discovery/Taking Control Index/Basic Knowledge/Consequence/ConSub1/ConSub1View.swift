//
//  ConSub1View.swift
//  Calmscient
//
//  SwiftUI Fatalities and injuries screen (parity with legacy `ConSub1VC`).
//
//  Vivek
//  25 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ConSub1View: View {

    @ObservedObject var viewModel: ConSub1ViewModel

    private let pageBackground = Color("AppBackGroundColor")

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    BasicStandardDrinkHeaderView(title: viewModel.content.headerTitle)

                    HStack {
                        Spacer()
                        ConSub1SpotlightButtonView(onTap: viewModel.spotlightTapped)
                    }

                    ModerationIntroTextView(text: viewModel.content.introText)

                    ModerationIntroTextView(text: viewModel.content.factorIntroText)

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

            if viewModel.isDidYouKnowAlertPresented {
                ConSub1DidYouKnowAlertView(
                    alert: viewModel.alertContent,
                    onClose: viewModel.dismissDidYouKnowAlert
                )
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(pageBackground.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.25), value: viewModel.isDidYouKnowAlertPresented)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("ConSub1 fatalities screen") {
    let viewModel = ConSub1ViewModel()
    viewModel.applyPreviewState()
    return ConSub1View(viewModel: viewModel)
}

@available(iOS 16.0, *)
#Preview("ConSub1 with alert") {
    let viewModel = ConSub1ViewModel()
    viewModel.applyPreviewState()
    viewModel.isDidYouKnowAlertPresented = true
    return ConSub1View(viewModel: viewModel)
}
#endif
