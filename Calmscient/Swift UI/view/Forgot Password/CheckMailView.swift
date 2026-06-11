//
//  CheckMailView.swift
//  Calmscient
//
//  Vivek
//  14 May 2026
//
import SwiftUI

@available(iOS 16.0, *)
struct CheckMailView: View {
    @ObservedObject var viewModel: CheckMailViewModel
    @FocusState private var focusedIndex: Int?

    private let digitCount = 4

    var body: some View {
        ZStack(alignment: .bottom) {
            LoginDesignSystem.ColorName.pageBackground
                .ignoresSafeArea()

            Image("waveBackground")
                .frame(height: 180)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea(edges: .bottom)

            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        LoginBrandingHeaderView()
                            .padding(.top, 36)
                            .padding(.bottom, 36)

                        VStack(alignment: .leading, spacing: 0) {
                            Text(AppHelper.getLocalizeString(str: "Check your email"))
                                .font(LoginDesignSystem.Typography.lexendMedium(size: 20))
                                .foregroundStyle(LoginDesignSystem.ColorName.navy)
                                .padding(.top, 24)

                            instructionText
                                .font(LoginDesignSystem.Typography.lexendLight(size: 16))
                                .foregroundStyle(LoginDesignSystem.ColorName.titleGray)
                                .padding(.top, 16)

                            otpRow
                                .padding(.top, 28)

                            LoginGradientButton(
                                title: AppHelper.getLocalizeString(str: "Verify Code"),
                                isEnabled: !viewModel.isBusy,
                                action: { viewModel.verifyCode() }
                            )
                            .padding(.top, 28)

                            resendRow
                                .padding(.top, 24)
                                .padding(.bottom, 40)
                        }
                        .padding(.horizontal, 28)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(minHeight: geometry.size.height)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .onAppear {
            focusedIndex = 0
        }
    }

    private var instructionText: some View {
        let plain = viewModel.instructionPlainText
        var attributed = AttributedString(plain)
        if let range = attributed.range(of: viewModel.email) {
            attributed[range].foregroundColor = Color("AppThemeColor")
        }
        return Text(attributed)
    }

    private var otpRow: some View {
        HStack(spacing: 12) {
            ForEach(0..<digitCount, id: \.self) { index in
                TextField("", text: Binding(
                    get: { viewModel.digits[index] },
                    set: { newValue in
                        if let next = viewModel.setDigit(at: index, raw: newValue) {
                            focusedIndex = next
                        }
                    }
                ))
                .focused($focusedIndex, equals: index)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(LoginDesignSystem.Typography.lexendMedium(size: 20))
                .foregroundStyle(LoginDesignSystem.ColorName.navy)
                .frame(width: 52, height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color("AppBorderColor"), lineWidth: 1)
                )
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var resendRow: some View {
        HStack(spacing: 0) {
            Text(AppHelper.getLocalizeString(str: "check_mail_resend_prompt"))
                .font(LoginDesignSystem.Typography.lexendLight(size: 16))
                .foregroundStyle(LoginDesignSystem.ColorName.titleGray)
            Text(AppHelper.getLocalizeString(str: "Resend email"))
                .font(LoginDesignSystem.Typography.lexendLight(size: 16))
                .foregroundStyle(Color("AppThemeColor"))
                .underline()
                .onTapGesture {
                    guard !viewModel.isBusy else { return }
                    viewModel.resendOTP()
                }
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Check mail") {
    CheckMailView(viewModel: CheckMailViewModel(email: "user@example.com"))
}
#endif
