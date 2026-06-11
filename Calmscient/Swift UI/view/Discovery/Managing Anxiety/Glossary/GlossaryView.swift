//
//  GlossaryView.swift
//  Calmscient
//
//  SwiftUI glossary list (parity with legacy `GlossyController`).
//
//  Vivek
//  19 May 2026
//

import SwiftUI

struct GlossaryView: View {

    @ObservedObject var viewModel: GlossaryViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                ForEach(viewModel.terms) { term in
                    GlossaryTermCardView(
                        term: term,
                        isExpanded: viewModel.isExpanded(termID: term.id),
                        onToggle: { viewModel.toggleTerm(id: term.id) }
                    )
                    .animation(.easeInOut(duration: 0.25), value: viewModel.expandedTermID)
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 13)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
    }
}

#if DEBUG
#Preview("Glossary list") {
    let viewModel = GlossaryViewModel()
    viewModel.applyPreviewState(expandedTermID: 1)
    return GlossaryView(viewModel: viewModel)
}
#endif
