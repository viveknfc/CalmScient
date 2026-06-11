//
//  SmokingControlView.swift
//  Calmscient
//
//  SwiftUI Smoking tab content for Taking Control index.
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct SmokingControlView: View {

    @ObservedObject var viewModel: SmokingControlViewModel

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    statsRow
                    menuSection
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

            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            ForEach(viewModel.statCards) { card in
                TakingControlStatCardView(card: card)
            }
        }
    }

    private var menuSection: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.menuItems) { item in
                TakingControlMenuButtonView(item: item) {
                    viewModel.openMenuItem(at: item.id)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 16)
        }
    }

    private var resourcesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.resourcesSectionTitle)
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
#Preview("Smoking control") {
    let viewModel = SmokingControlViewModel()
    viewModel.applyPreviewState(
        statCards: TakingControlIndexPreviewData.smokingStats(),
        menuItems: [
            TakingControlMenuItemPresentation(id: 0, title: "Basic knowledge", isActive: true, showsCheckmark: true),
            TakingControlMenuItemPresentation(id: 1, title: "Make a plan", isActive: false, showsCheckmark: false),
            TakingControlMenuItemPresentation(id: 2, title: "Stay focused", isActive: false, showsCheckmark: false),
            TakingControlMenuItemPresentation(id: 3, title: "My progress", isActive: false, showsCheckmark: false),
        ]
    )
    return SmokingControlView(viewModel: viewModel)
}
#endif
