//
//  TakingControlIntroChoiceButton.swift
//  Calmscient
//
//  Yes / No choice control for the CAGE-AID intro questionnaire.
//
//  Vivek
//  19 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TakingControlIntroChoiceButton: View {

    let title: String
    let isSelected: Bool
    let action: () -> Void

    private var selectedColor: Color {
        Color(red: 0.388, green: 0.420, blue: 0.702)
    }

    var body: some View {
        Button(action: action) {

            HStack(spacing: 12) {

                ZStack {
                    Circle()
                        .stroke(
                            isSelected ? selectedColor : Color.gray.opacity(0.5),
                            lineWidth: 2
                        )
                        .frame(width: 20, height: 20)

                    if isSelected {
                        Circle()
                            .fill(selectedColor)
                            .frame(width: 10, height: 10)
                    }
                }

                Text(title)
                    .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                    .foregroundStyle(Color.primary)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
//            .background(
//                RoundedRectangle(cornerRadius: 12, style: .continuous)
//                    .fill(Color.white)
//                    .shadow(
//                        color: Color.black.opacity(0.08),
//                        radius: 3,
//                        x: 0,
//                        y: 2
//                    )
//            )
        }
        .buttonStyle(.plain)
    }
}

//@available(iOS 16.0, *)
//struct TakingControlIntroChoiceButton: View {
//
//    let title: String
//    let isSelected: Bool
//    let action: () -> Void
//
//    private var selectedFill: Color {
//        Color(red: 0.388, green: 0.420, blue: 0.702)
//    }
//
//    var body: some View {
//        Button(action: action) {
//            Text(title)
//                .font(LoginDesignSystem.Typography.lexendLight(size: 12))
//                .foregroundStyle(isSelected ? Color.white : Color.primary)
//                .frame(maxWidth: .infinity)
//                .padding(.vertical, 8)
//                .background(
//                    RoundedRectangle(cornerRadius: 8, style: .continuous)
//                        .fill(isSelected ? selectedFill : Color.white)
//                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
//                )
//                .overlay(
//                    RoundedRectangle(cornerRadius: 8, style: .continuous)
//                        .stroke(Color.black.opacity(0.08), lineWidth: isSelected ? 0 : 1)
//                )
//
//        }
//        .buttonStyle(.plain)
//    }
//}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Selected") {
    TakingControlIntroChoiceButton(title: "Yes", isSelected: true, action: {})
        .padding()
}

@available(iOS 16.0, *)
#Preview("Unselected") {
    TakingControlIntroChoiceButton(title: "No", isSelected: false, action: {})
        .padding()
}
#endif
