//
//  MindfulnessBodyTextView.swift
//  Calmscient
//
//  Primary or secondary copy block for a mindfulness step.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct MindfulnessBodyTextView: View {

    let content: MindfulnessTextContent
    let isDarkMode: Bool

    var body: some View {
        Group {
            switch content {
            case .none:
                EmptyView()
            case .attributed(let attributed):
                Text(attributed)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            case .plain:
                if let plain = MindfulnessPresentation.plainText(for: content, isDarkMode: isDarkMode) {
                    Text(plain.text)
                        .font(plain.font)
                        .foregroundStyle(plain.color)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Mindfulness body — intro") {
    let step = MindfulnessPresentation.previewStep(index: 0)
    return VStack(alignment: .leading, spacing: 20) {
        MindfulnessBodyTextView(content: step.primaryText, isDarkMode: false)
        MindfulnessBodyTextView(content: step.secondaryText, isDarkMode: false)
    }
    .padding(.horizontal, 20)
}
#endif
