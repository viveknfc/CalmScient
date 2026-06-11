//
//  ProgressOnCourseWorkRowView.swift
//  Calmscient
//
//  Single course row with completion percentage and disclosure arrow.
//
//  Vivek
//  18 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ProgressOnCourseWorkRowView: View {

    let title: String
    let percentageText: String
    let onTap: () -> Void

    private let titleColor = Color("424242Color")
    private let cardBackground = Color("AppViewContentColor")

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Text(title)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                    .foregroundStyle(titleColor)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(percentageText)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                    .foregroundStyle(titleColor)

                if let arrow = UIImage(named: "MedicationsCellArrow") {
                    Image(uiImage: arrow)
                        .renderingMode(.original)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(cardBackground)
                    .progressOnCourseWorkCardShadow()
            )
            
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Course row") {
    ProgressOnCourseWorkRowView(
        title: "Changing your response to stress",
        percentageText: "0.0%",
        onTap: {}
    )
    .padding(.horizontal, 16)
}
#endif
