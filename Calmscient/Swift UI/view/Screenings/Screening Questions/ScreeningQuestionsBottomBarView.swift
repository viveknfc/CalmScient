//
//  ScreeningQuestionsBottomBarView.swift
//  Calmscient
//
//  Back / forward / complete controls for screening questionnaire pager.
//
//  Vivek
//  15 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ScreeningQuestionsBottomBarView: View {

    @ObservedObject var viewModel: ScreeningQuestionsViewModel

    var body: some View {
        HStack {
            if viewModel.showsBackwardButton {
                navCircleButton(imageName: "backward", action: viewModel.goBackward)
            }

            Spacer()

            if viewModel.showsCompleteButton {
                completeButton
            } else if viewModel.showsForwardButton {
                navCircleButton(imageName: "forwardArrow", action: viewModel.goForward)
            }
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 32)
    }

    private var completeButton: some View {
        Button(action: viewModel.completeScreening) {
            Text("Complete".localized)
                .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .frame(height: 41)
                .background(
                    Capsule(style: .continuous)
                        .fill(LoginDesignSystem.ColorName.purple)
                )
        }
        .buttonStyle(.plain)
    }

    private func navCircleButton(imageName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 41, height: 41)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Bottom bar — first page") {
    let viewModel = ScreeningQuestionsViewModel()
    viewModel.applyPreviewState(
        questions: ScreeningQuestionPagePresentationPreviewData.sampleQuestionnaire(),
        pageNumber: 0
    )
    return ScreeningQuestionsBottomBarView(viewModel: viewModel)
}

@available(iOS 16.0, *)
#Preview("Bottom bar — last page") {
    let questions = ScreeningQuestionPagePresentationPreviewData.sampleQuestionnaire()
    let viewModel = ScreeningQuestionsViewModel()
    viewModel.applyPreviewState(questions: questions, pageNumber: max(questions.count - 1, 0))
    return ScreeningQuestionsBottomBarView(viewModel: viewModel)
}
#endif
