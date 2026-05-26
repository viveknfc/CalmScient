//
//  DrinkingCountStepperView.swift
//  Calmscient
//
//  Minus / plus stepper control for drink quantity cards.
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct DrinkingCountStepperView: View {

    let onDecrement: () -> Void
    let onIncrement: () -> Void

    private let controlBorderColor = Color(hex: "#F2F2F2")

    var body: some View {
        HStack(spacing: 0) {
            stepButton(symbol: "minus", action: onDecrement)
            Rectangle()
                .fill(controlBorderColor)
                .frame(width: 1)
                .frame(maxHeight: .infinity)
            stepButton(symbol: "plus", action: onIncrement)
        }
        .frame(height: 24)
        .background(
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(controlBorderColor, lineWidth: 1)
                .shadow(color: .black.opacity(0.18), radius: 1, x: 0, y: 1)
        )
    }

    private func stepButton(symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Drinking count stepper") {
    DrinkingCountStepperView(onDecrement: {}, onIncrement: {})
        .padding()
        .frame(width: 160)
}
#endif
