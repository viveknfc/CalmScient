//
//  ConSub1DidYouKnowAlertView.swift
//  Calmscient
//
//  Did you know overlay for Fatalities and injuries (parity with `AlertVC`).
//
//  Vivek
//  25 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ConSub1DidYouKnowAlertView: View {

    let alert: ConSub1AlertPresentation
    let onClose: () -> Void

    private let dimmedOverlay = Color(red: 0.373, green: 0.373, blue: 0.373).opacity(0.9)
    private let bodyFont = LoginDesignSystem.Typography.lexendLight(size: 14)
    private let bodyColor = Color("424242Color")
    private let titleFont = LoginDesignSystem.Typography.lexendMedium(size: 16)

    var body: some View {
        ZStack {
            dimmedOverlay
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)

            card
                .padding(.horizontal, 30)
        }
    }

    private var card: some View {
        VStack(spacing: 0) {
            ZStack {
                Text(alert.title)
                    .font(titleFont)
                    .foregroundStyle(Color.primary)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)

                HStack {
                    Spacer()
                    ConSub1DidYouKnowCloseButtonView(onClose: onClose)
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 10)

            ScrollView {
                Text(alert.bodyText)
                    .font(bodyFont)
                    .foregroundStyle(bodyColor)
                    .lineSpacing(6)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
            }
            .frame(maxHeight: 350)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 420)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
        )
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("ConSub1 did you know alert") {
    ConSub1DidYouKnowAlertView(
        alert: ConSub1Presentation.previewAlert(),
        onClose: {}
    )
}
#endif
