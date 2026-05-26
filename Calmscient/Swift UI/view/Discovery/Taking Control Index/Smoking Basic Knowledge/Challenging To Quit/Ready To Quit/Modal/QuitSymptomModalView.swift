//
//  QuitSymptomModalView.swift
//  Calmscient
//
//  Ready-to-quit symptom modal overlay (parity with storyboard symptom VCs).
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct QuitSymptomModalView: View {

    @ObservedObject var viewModel: QuitSymptomModalViewModel

    private let dimmedOverlay = Color(red: 0.337, green: 0.337, blue: 0.337).opacity(0.9)
    private let titleColor = Color(hex: "#6E6BB3")
    private let screenPadding: CGFloat = 10
    private let verticalInset: CGFloat = 50

    var body: some View {
        GeometryReader { geometry in
            let maxCardHeight = max(
                200,
                geometry.size.height
                    - geometry.safeAreaInsets.top
                    - geometry.safeAreaInsets.bottom
                    - (verticalInset * 2)
            )

            ZStack {
                dimmedOverlay
                    .ignoresSafeArea()
                    .onTapGesture { viewModel.close() }

                ViewThatFits(in: .vertical) {
                    card(scrollsWhenOverflowing: false)
                    card(scrollsWhenOverflowing: true, maxHeight: maxCardHeight)
                }
                .padding(.horizontal, screenPadding)
                .padding(.vertical, verticalInset)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .ignoresSafeArea()
    }

    private func card(scrollsWhenOverflowing: Bool, maxHeight: CGFloat? = nil) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            cardHeader

            if scrollsWhenOverflowing {
                ScrollView {
                    cardScrollableBody
                }
                .scrollIndicators(.visible)
            } else {
                cardScrollableBody
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .frame(height: scrollsWhenOverflowing ? maxHeight : nil)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(.systemBackground))
        )
    }

    private var cardHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            QuitSymptomModalCloseButtonView(onClose: viewModel.close)
                .padding(.bottom, 4)

            Text(viewModel.content.title)
                .font(LoginDesignSystem.Typography.lexendMedium(size: 16))
                .foregroundStyle(titleColor)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 10)
        }
    }

    private var cardScrollableBody: some View {
        VStack(alignment: .leading, spacing: 10) {
            QuitSymptomModalContentBlocksView(
                viewModel: viewModel,
                blocks: viewModel.content.blocks
            )

            QuitSymptomModalGoBackButtonView(
                title: viewModel.content.goBackButtonTitle,
                onTap: viewModel.close
            )
            .padding(.top, 10)
        }
        .padding(.bottom, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Nicotine cravings modal") {
    let viewModel = QuitSymptomModalViewModel(topic: .nicotineCravings)
    return QuitSymptomModalView(viewModel: viewModel)
}

@available(iOS 16.0, *)
#Preview("Irritability modal") {
    let viewModel = QuitSymptomModalViewModel(topic: .irritability)
    return QuitSymptomModalView(viewModel: viewModel)
}

@available(iOS 16.0, *)
#Preview("Difficulty concentrating modal") {
    let viewModel = QuitSymptomModalViewModel(topic: .difficultyConcentrating)
    return QuitSymptomModalView(viewModel: viewModel)
}

@available(iOS 16.0, *)
#Preview("Increased appetite modal") {
    let viewModel = QuitSymptomModalViewModel(topic: .increasedAppetite)
    return QuitSymptomModalView(viewModel: viewModel)
}

@available(iOS 16.0, *)
#Preview("Sleep disturbances modal") {
    let viewModel = QuitSymptomModalViewModel(topic: .sleepDisturbances)
    return QuitSymptomModalView(viewModel: viewModel)
}

@available(iOS 16.0, *)
#Preview("Depression and anxiety modal") {
    let viewModel = QuitSymptomModalViewModel(topic: .depressionAnxiety)
    return QuitSymptomModalView(viewModel: viewModel)
}
#endif
