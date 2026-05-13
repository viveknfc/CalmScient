//
//  LoginCheckboxesSection.swift
//  Calmscient
//

import SwiftUI

struct LoginCheckboxesSection: View {
    @Binding var acceptTermsSelected: Bool
    @Binding var rememberMeSelected: Bool
    var onTermsLink: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                Button {
                    acceptTermsSelected.toggle()
                } label: {
                    checkboxFilled(isOn: acceptTermsSelected)
                }
                .buttonStyle(.plain)

                termsLabel
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                rememberMeSelected.toggle()
            } label: {
                HStack(spacing: 12) {
                    checkboxOutline(isOn: rememberMeSelected)
                    Text(AppHelper.getLocalizeString(str: "Remember me"))
                        .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                        .foregroundStyle(LoginDesignSystem.ColorName.footerGray)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var termsLabel: some View {
        let full = NSLocalizedString("Accept Terms and Conditions", comment: "")
        let linkPhrase = NSLocalizedString("Terms and Conditions", comment: "")
        return Group {
            if let range = full.range(of: linkPhrase) {
                let before = String(full[..<range.lowerBound])
                let after = String(full[range.upperBound...])
                HStack(spacing: 0) {
                    Text(before)
                    Button(action: onTermsLink) {
                        Text(linkPhrase)
                            .underline()
                            .foregroundStyle(LoginDesignSystem.ColorName.linkBlue)
                    }
                    .buttonStyle(.plain)
                    Text(after)
                }
                .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                .foregroundStyle(LoginDesignSystem.ColorName.titleGray)
            } else {
                Text(full)
                    .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                    .foregroundStyle(LoginDesignSystem.ColorName.titleGray)
            }
        }
    }

    private func checkboxFilled(isOn: Bool) -> some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(
                isOn
                ? AnyShapeStyle(LoginDesignSystem.ColorName.loginGradient)
                : AnyShapeStyle(Color.clear)
            )
            .frame(width: 22, height: 22)
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(LoginDesignSystem.ColorName.purple, lineWidth: isOn ? 0 : 1.5)
            )
            .overlay {
                if isOn {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.white)
                }
            }
    }

    private func checkboxOutline(isOn: Bool) -> some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(isOn ? LoginDesignSystem.ColorName.purple.opacity(0.15) : Color.clear)
            .frame(width: 22, height: 22)
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(LoginDesignSystem.ColorName.loginGradient, lineWidth: 1.5)
            )
            .overlay {
                if isOn {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(LoginDesignSystem.ColorName.loginGradient)
                }
            }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Checkboxes") {
    struct Holder: View {
        @State var a = true
        @State var r = false
        var body: some View {
            LoginCheckboxesSection(acceptTermsSelected: $a, rememberMeSelected: $r, onTermsLink: {})
                .padding()
        }
    }
    return Holder()
}
#endif
