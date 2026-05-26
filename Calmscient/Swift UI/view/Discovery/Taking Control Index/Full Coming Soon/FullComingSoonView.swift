//
//  FullComingSoonView.swift
//  Calmscient
//
//  Full-version coming soon modal (parity with storyboard `FullComingSoonVC`).
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct FullComingSoonView: View {

    @ObservedObject var viewModel: FullComingSoonViewModel

    private let overlayGray = Color(red: 0.337, green: 0.337, blue: 0.337)
    private let titleGray = Color(red: 0.337, green: 0.337, blue: 0.337)
    private let closeBorderGray = Color(red: 0.392, green: 0.392, blue: 0.392)

    var body: some View {
        ZStack {
            overlayGray.opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture { viewModel.close() }

            cardContent
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
        }
    }

    private var cardContent: some View {
        VStack(spacing: 0) {
            Text(viewModel.title)
                .font(LoginDesignSystem.Typography.lexendMedium(size: 25))
                .foregroundStyle(titleGray)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 40)

            Text(viewModel.subtitle)
                .font(LoginDesignSystem.Typography.lexendMedium(size: 17))
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 20)

            Text(viewModel.featuresQuestion)
                .font(LoginDesignSystem.Typography.lexendLight(size: 16))
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.top, 20)

            ForEach(viewModel.featureItems) { item in
                featureSection(item)
            }

            HStack {
                Spacer()
                closeButton
            }
            .padding(.top, 20)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    @ViewBuilder
    private func featureSection(_ item: FullComingSoonFeatureItem) -> some View {
        VStack(spacing: 10) {
            featureIcons(for: item)
                .padding(.top, 10)

            Text(viewModel.localizedDescription(for: item))
                .font(LoginDesignSystem.Typography.lexendLight(size: 16))
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 60)
        }
    }

    @ViewBuilder
    private func featureIcons(for item: FullComingSoonFeatureItem) -> some View {
        if item.imageNames.count > 1 {
            HStack(spacing: 20) {
                ForEach(item.imageNames, id: \.self) { name in
                    featureIcon(name)
                }
            }
        } else if let name = item.imageNames.first {
            featureIcon(name)
        }
    }

    private func featureIcon(_ name: String) -> some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
    }

    private var closeButton: some View {
        Button(action: { viewModel.close() }) {
            Text(viewModel.closeButtonTitle)
                .font(LoginDesignSystem.Typography.lexendLight(size: 16))
                .foregroundStyle(Color(.darkGray))
                .frame(width: 100, height: 30)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(closeBorderGray, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Full coming soon") {
    FullComingSoonView(viewModel: FullComingSoonViewModel())
}
#endif
