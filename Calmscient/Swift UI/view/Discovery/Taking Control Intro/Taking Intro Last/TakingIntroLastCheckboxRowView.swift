//
//  TakingIntroLastCheckboxRowView.swift
//  Calmscient
//
//  “Do not show again” row with checkbox images (parity with `TakingIntroLastVC`).
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TakingIntroLastCheckboxRowView: View {
    let label: String
    @Binding var isOn: Bool
    let onToggle: (Bool) -> Void

    var body: some View {
        Button {
            let next = !isOn
            isOn = next
            onToggle(next)
        } label: {
            HStack(alignment: .center, spacing: 10) {
                Image(isOn ? "checkbox" : "uncheck_img")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)

                Text(label)
                    .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Checkbox row — off") {
    struct Host: View {
        @State private var on = false
        var body: some View {
            TakingIntroLastCheckboxRowView(
                label: "Do not show this tutorial from the next time",
                isOn: $on,
                onToggle: { _ in }
            )
            .padding()
            .background(Color("AppBackGroundColor"))
        }
    }
    return Host()
}

@available(iOS 16.0, *)
#Preview("Checkbox row — on") {
    struct Host: View {
        @State private var on = true
        var body: some View {
            TakingIntroLastCheckboxRowView(
                label: "Do not show this tutorial from the next time",
                isOn: $on,
                onToggle: { _ in }
            )
            .padding()
            .background(Color("AppBackGroundColor"))
        }
    }
    return Host()
}
#endif
