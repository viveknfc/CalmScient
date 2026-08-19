//
//  NeedToTalkView.swift
//  Calmscient
//
//  SwiftUI emergency resources screen (parity with legacy `NeedToTalkViewController`).
//
//  Storyboard parity: provider card pinned 1pt below the safe-area top, list directly
//  underneath it ending 32pt above the bottom of the view. The legacy table had
//  `allowsSelection = NO` and default separators, so this uses a plain scroll view with
//  dividers rather than a `List` (no selection highlight, no inset grouping).
//

import SwiftUI

@available(iOS 16.0, *)
struct NeedToTalkView: View {

    @ObservedObject var viewModel: NeedToTalkViewModel

    var body: some View {
        VStack(spacing: 0) {

            NeedToTalkProviderCardView(
                provider: viewModel.provider,
                onPhoneTap: { viewModel.callProvider() }
            )
            .padding(.top, 1)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.rows) { row in
                        NeedToTalkRowView(
                            row: row,
                            onLearnMore: { viewModel.openLearnMore(for: row) }
                        )

                        // Default `UITableView` separator inset.
                        Divider()
                            .padding(.leading, 16)
                    }
                }
            }
            .background(Color(uiColor: .systemBackground))

            // Legacy table bottom constraint: view.bottom - 32.
            Spacer(minLength: 0)
                .frame(height: 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(uiColor: .systemBackground))
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Emergency resources") {
    NeedToTalkView(viewModel: NeedToTalkViewModel())
}
#endif
