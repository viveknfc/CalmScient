//
//  ProfilePrivacyView.swift
//  Calmscient
//
//  Vivek
//  14 May 2026
//
//  SwiftUI privacy sheet (replaces storyboard `ProfilePrivacyViewController`).
//

import SwiftUI

struct ProfilePrivacyView: View {
    @ObservedObject var viewModel: ProfilePrivacyViewModel

    private let circleSize: CGFloat = 30
    private let iconPointSize: CGFloat = 12

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)

            Text(viewModel.privacyDescription)
                .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

            if viewModel.isLoading && viewModel.consentItems.isEmpty {
                Spacer(minLength: 24)
                ProgressView()
                    .tint(LoginDesignSystem.ColorName.purple)
                Spacer(minLength: 24)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(viewModel.consentItems.enumerated()), id: \.element.id) { index, item in
                            ProfilePrivacyConsentRowView(
                                title: item.consentListName,
                                isOn: item.isConsentGranted,
                                onTap: { viewModel.toggleConsent(at: index) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .background(Color.white)
        .onAppear { viewModel.onAppear() }
    }

    private var header: some View {
        ZStack {
            HStack {
                Spacer()
                closeButton
            }

            Text(viewModel.privacyTitle)
                .font(LoginDesignSystem.Typography.lexendMedium(size: 18))
                .foregroundStyle(Color.primary)
        }
    }

    private var closeButton: some View {
        Button {
            viewModel.close()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: iconPointSize, weight: .semibold))
                .foregroundStyle(LoginDesignSystem.ColorName.purpleDeep)
                .frame(width: circleSize, height: circleSize)
                .background(
                    Circle()
                        .fill(LoginDesignSystem.ColorName.lavenderWave)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Close"))
    }
}

#if DEBUG
struct ProfilePrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProfilePrivacyView(viewModel: ProfilePrivacyViewModel.previewFilled())
            ProfilePrivacyView(viewModel: ProfilePrivacyViewModel())
        }
    }
}
#endif
