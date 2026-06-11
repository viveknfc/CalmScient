//
//  GlossaryTermRowPresentation.swift
//  Calmscient
//
//  Row model for glossary expandable terms (parity with `GlossyController`).
//
//  Vivek
//  19 May 2026
//

import Foundation

@available(iOS 16.0, *)
struct GlossaryTermRowPresentation: Identifiable {
    let id: Int
    let title: String
    let summary: String
    let letterInitial: String

    init(index: Int) {
        id = index
        let localizedTitle = "gls_term_\(index)".localized
        title = localizedTitle
        summary = "gls_sum_\(index)".localized
        letterInitial = String(localizedTitle.prefix(1)).uppercased()
    }
}

#if DEBUG
@available(iOS 16.0, *)
enum GlossaryTermRowPresentationPreviewData {
    static let sampleTerms: [GlossaryTermRowPresentation] = (1...5).map { GlossaryTermRowPresentation(index: $0) }
}
#endif
