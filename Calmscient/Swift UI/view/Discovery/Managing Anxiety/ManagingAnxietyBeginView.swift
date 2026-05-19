//
//  ManagingAnxietyBeginView.swift
//  Calmscient
//
//  SwiftUI intro for the Managing Anxiety discovery course.
//
//  Vivek
//  19 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ManagingAnxietyBeginView: View {

    @ObservedObject var viewModel: ManagingAnxietyBeginViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(viewModel.headlineText)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 16))
                    .foregroundStyle(Color.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text(viewModel.bodyText)
                    .font(LoginDesignSystem.Typography.lexendLight(size: 16))
                    .foregroundStyle(Color.white)
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 20)

                Text(viewModel.readyQuestionText)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 18))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)

                beginButton
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .background {
            Image("managingScreen3")
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea()
        }
    }

    private var beginButton: some View {
        Button(action: viewModel.beginManagingAnxietyCourse) {
            Text(viewModel.beginButtonTitle)
                .font(LoginDesignSystem.Typography.lexendSemiBold(size: 16))
                .foregroundStyle(Color.white)
                .frame(width: 247, height: 45)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(LoginDesignSystem.ColorName.loginGradient)
                )
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Managing anxiety begin") {
    NavigationStack {
        ManagingAnxietyBeginView(viewModel: ManagingAnxietyBeginViewModel())
            .navigationTitle("The Discovery")
            .navigationBarTitleDisplayMode(.inline)
    }
}
#endif
