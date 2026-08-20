//
//  DrinkingControlView.swift
//  Calmscient
//
//  SwiftUI Drinking tab content for Taking Control index.
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct DrinkingControlView: View {

    @ObservedObject var viewModel: DrinkingControlViewModel

    private let resourcesTitle = "Resources".localized

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    statsRow
                    TakingControlCalendarStripView(viewModel: viewModel)
                    menuSection
                    trackerSection
                    resourcesSection
                    if PatientLanguagePreference.shouldShowNeedToTalkButton() {
                        LoginGradientButton(title: viewModel.needToTalkButtonTitle) {
                            viewModel.openNeedToTalk()
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
            }

            // Loading is shown by the app-wide toast activity indicator that the view model
            // drives (`showToastActivity` / `hideToastActivity`). A second SwiftUI
            // `ProgressView` overlay here would render a differently styled spinner on top
            // of it, so it is intentionally not used.
        }
        .overlay(alignment: .topTrailing) {
            if viewModel.showsInfoPopover {
                TakingControlInfoPopoverView(
                    items: viewModel.infoLegendItems,
                    onClose: { viewModel.dismissInfoPopover() }
                )
                .padding(.top, 120)
                .padding(.trailing, 8)
                .transition(.opacity)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if viewModel.showsInfoPopover {
                viewModel.dismissInfoPopover()
            }
        }
    }

    private var statsRow: some View {
        
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 2) {
                ForEach(viewModel.statCards) { card in
                    TakingControlStatCardView(card: card)
                }
                
            }

            HStack {
                
                Spacer()
                
                Button(action: { viewModel.toggleInfoPopover() }) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(LoginDesignSystem.ColorName.primaryGradientTop)
                }
                .padding(.horizontal, 16)
                .buttonStyle(.plain)
            }
        }
    }

    private var menuSection: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.menuItems) { item in
                TakingControlMenuButtonView(item: item) {
                    viewModel.openMenuItem(at: item.id)
                }
            }
            .padding(.bottom, 4)
        }
        .padding(16)
    }

    private var trackerSection: some View {
        HStack(spacing: 12) {
            TakingControlTrackerActionCardView(
                title: "Drink tracker".localized,
                imageName: "BeerWine1",
                onTap: { viewModel.openDrinkTracker() }
            )
            TakingControlTrackerActionCardView(
                title: "Events tracker".localized,
                imageName: "calenderi",
                onTap: { viewModel.openEventsTracker() }
            )
        }
        .padding(.horizontal, 16)
    }

    private var resourcesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(resourcesTitle)
                .font(LoginDesignSystem.Typography.lexendMedium(size: 18))
                .foregroundStyle(Color.primary)

            ForEach(viewModel.resourceRows) { row in
                TakingControlResourceCardView(row: row) {
                    viewModel.openResource(at: row.id)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Drinking control") {
    let viewModel = DrinkingControlViewModel()
    viewModel.applyPreviewState(
        statCards: TakingControlIndexPreviewData.drinkingStats(),
        calendarEvents: TakingControlIndexPresentation.previewCalendarEvents()
    )
    return DrinkingControlView(viewModel: viewModel)
}
#endif
