//
//  ScreeningQuestionsOptionRowView.swift
//  Calmscient
//
//  Single answer option row for screening questionnaire.
//
//  Vivek
//  15 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ScreeningQuestionsOptionRowView: View {

    let option: ScreeningQuestionOptionPresentation
    let onTap: () -> Void

    private var selectedFill: Color {
        Color("medicationscelldefaulttextcolor")
    }

    private var defaultFill: Color {
        Color("AppViewContentColor")
    }

    private var borderColor: Color {
        Color("AppViewBorderColor")
    }

    private var selectedTextColor: Color { .white }

    private var defaultTextColor: Color {
        Color("424242Color")
    }

    var body: some View {
        Button(action: onTap) {
            Text(option.label)
                .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                .foregroundStyle(option.isSelected ? selectedTextColor : defaultTextColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(option.isSelected ? selectedFill : defaultFill)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(borderColor, lineWidth: 1)
                )
                .shadow(
                    color: Color("AppViewShadowColor").opacity(0.2),
                    radius: 2,
                    x: 0,
                    y: 1
                )
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Option — unselected") {
    ScreeningQuestionsOptionRowView(
        option: ScreeningQuestionOptionPresentation(
            id: "0-0",
            label: "Not at all",
            index: 0,
            isSelected: false
        ),
        onTap: {}
    )
    .padding()
}

@available(iOS 16.0, *)
#Preview("Option — selected") {
    ScreeningQuestionsOptionRowView(
        option: ScreeningQuestionOptionPresentation(
            id: "0-1",
            label: "Several days",
            index: 1,
            isSelected: true
        ),
        onTap: {}
    )
    .padding()
}
#endif
