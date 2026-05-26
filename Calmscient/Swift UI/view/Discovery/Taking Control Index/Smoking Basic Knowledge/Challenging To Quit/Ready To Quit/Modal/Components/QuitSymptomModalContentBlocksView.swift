//
//  QuitSymptomModalContentBlocksView.swift
//  Calmscient
//
//  Renders localized content blocks inside a symptom modal card.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct QuitSymptomModalContentBlocksView: View {

    @ObservedObject var viewModel: QuitSymptomModalViewModel

    let blocks: [QuitSymptomModalBlock]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                blockView(for: block)
            }
        }
    }

    @ViewBuilder
    private func blockView(for block: QuitSymptomModalBlock) -> some View {
        switch block {
        case .bodyText(let text):
            QuitSymptomModalBodyTextView(text: text)
        case .purpleHeading(let text):
            QuitSymptomModalPurpleHeadingView(text: text)
        case .section(let heading, let body):
            QuitSymptomModalSectionView(heading: heading, bodyText: body)
        case .timelineSteps(let steps):
            QuitSymptomModalTimelineBlockView(steps: steps)
        case .highlighted(let fullTextKey, let accentKeys):
            QuitSymptomModalHighlightedTextView(
                attributedText: viewModel.attributedHighlightedText(
                    fullTextKey: fullTextKey,
                    accentPhraseKeys: accentKeys
                )
            )
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Quit symptom content blocks – nicotine") {
    let viewModel = QuitSymptomModalViewModel(topic: .nicotineCravings)
    return QuitSymptomModalContentBlocksView(
        viewModel: viewModel,
        blocks: viewModel.content.blocks
    )
    .padding()
}
#endif
