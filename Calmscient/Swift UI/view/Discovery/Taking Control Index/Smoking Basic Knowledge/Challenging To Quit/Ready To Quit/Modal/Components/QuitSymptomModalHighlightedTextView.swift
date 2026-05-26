//
//  QuitSymptomModalHighlightedTextView.swift
//  Calmscient
//
//  Body copy with purple accent phrases for symptom modals.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct QuitSymptomModalHighlightedTextView: View {

    let attributedText: AttributedString

    var body: some View {
        Text(attributedText)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Quit symptom highlighted text") {
    let text = QuitSymptomModalPresentation.makeHighlightedAttributedText(
        fullTextKey: "quit_symptom_nicotine_triggers_full",
        accentPhraseKeys: ["Know your triggers:", "Positive thoughts:"]
    )
    return QuitSymptomModalHighlightedTextView(attributedText: text)
        .padding()
}
#endif
