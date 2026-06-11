//
//  ConsequenceTopicsListView.swift
//  Calmscient
//
//  Vertical list of tappable consequence topic buttons.
//
//  Vivek
//  25 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ConsequenceTopicsListView: View {

    let rows: [ConsequenceTopicRowPresentation]
    let onTopicTap: (ConsequenceTopicRowPresentation) -> Void

    var body: some View {
        VStack(spacing: 20) {
            ForEach(rows) { row in
                ConsequenceTopicButtonView(title: row.title) {
                    onTopicTap(row)
                }
            }
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Consequence topics list") {
    ConsequenceTopicsListView(
        rows: ConsequencePresentation.previewContent().topicRows,
        onTopicTap: { _ in }
    )
    .padding(.horizontal, 20)
}
#endif
