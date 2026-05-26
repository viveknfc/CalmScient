//
//  DrinkingCountView.swift
//  Calmscient
//
//  SwiftUI drink counts calculator (parity with legacy `DrinkingCountVC`).
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct DrinkingCountView: View {

    @ObservedObject var viewModel: DrinkingCountViewModel

    var body: some View {
        VStack(spacing: 0) {
            DrinkingCountHeaderView(
                subtitle: viewModel.subtitleText,
                totalLabelLineOne: viewModel.totalLabelLineOne,
                totalLabelLineTwo: viewModel.totalLabelLineTwo,
                totalValue: viewModel.displayedTotalCount
            )

            Divider()
                .padding(.top, 12)

            Text(viewModel.selectionInstructionText)
                .font(LoginDesignSystem.Typography.lexendMedium(size: 14))
                .foregroundStyle(Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)

            ScrollView {
                DrinkingCountGridView(
                    rows: viewModel.drinkRows,
                    onIncrement: { viewModel.incrementQuantity(for: $0) },
                    onDecrement: { viewModel.decrementQuantity(for: $0) }
                )
                .padding(.bottom, viewModel.showsSaveButton ? 100 : 24)
            }

            if viewModel.showsSaveButton {
                LoginGradientButton(
                    title: viewModel.saveButtonTitle,
                    isEnabled: !viewModel.isSaving
                ) {
                    viewModel.saveDrinkCounts()
                }
                .padding(.bottom, 12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
        .overlay {
            if viewModel.isLoading || viewModel.isSaving {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Drink counts calculator") {
    let viewModel = DrinkingCountViewModel()
    viewModel.applyPreviewState(
        rows: DrinkCountRowPresentation.previewRows(),
        baselineTotal: 5.4,
        sessionDelta: 4.0,
        showsSave: true
    )
    return DrinkingCountView(viewModel: viewModel)
}
#endif
