//
//  ProfilePrivacyConsentRowView.swift
//  Calmscient
//
//  Vivek
//  14 May 2026
//
//  Single consent card with title and Yes/No pill control (matches legacy toggle imagery intent).
//

import SwiftUI

struct ProfilePrivacyConsentRowView: View {
    let title: String
    let isOn: Bool
    let onTap: () -> Void

    private let rowHeight: CGFloat = 70
    private let toggleWidth: CGFloat = 60
    private let knobSize: CGFloat = 28

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(title)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            consentPill
        }
        .padding(.horizontal, 16)
        .frame(height: rowHeight)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color(UIColor(named: "AppViewBorderColor") ?? UIColor.separator), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 1)
    }

    private var consentPill: some View {
        Button(action: onTap) {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule()
                    .fill(isOn ? LoginDesignSystem.ColorName.purple : Color(red: 0.88, green: 0.88, blue: 0.9))

                HStack(spacing: 0) {
                    if isOn {
                        Text("Yes".localized)
                            .font(LoginDesignSystem.Typography.lexendRegular(size: 10))
                            .foregroundStyle(.white)
                            .padding(.leading, 10)
                        Spacer(minLength: 4)
                    } else {
                        Spacer(minLength: 4)
                        Text("No".localized)
                            .font(LoginDesignSystem.Typography.lexendRegular(size: 10))
                            .foregroundStyle(Color("AppBorderColor"))
                            .padding(.trailing, 10)
                    }
                }

                Circle()
                    .fill(Color.white)
                    .frame(width: knobSize, height: knobSize)
                    .shadow(color: Color.black.opacity(0.12), radius: 2, x: 0, y: 1)
                    .padding(3)
            }
            .frame(width: toggleWidth, height: 25)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityValue(isOn ? "Yes".localized : "No".localized)
    }
}

#if DEBUG
struct ProfilePrivacyConsentRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProfilePrivacyConsentRowView(title: "Journaling", isOn: true, onTap: {})
            ProfilePrivacyConsentRowView(title: "Mood", isOn: false, onTap: {})
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
