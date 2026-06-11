//
//  JournalEntryView.swift
//  Calmscient
//
//  SwiftUI journal entry hub (questionnaire, diary, discovery).
//
//  Vivek
//  18 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
struct JournalEntryView: View {

    @ObservedObject var viewModel: JournalEntryViewModel
    @State private var draftJournalText = ""

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 12) {
                JournalEntrySearchBarView(
                    text: Binding(
                        get: { viewModel.searchText },
                        set: { viewModel.updateSearchFromUI($0) }
                    ),
                    placeholder: "search_placeholder".localized,
                    onCalendarTap: { viewModel.presentCalendarPicker() }
                )

                JournalEntryFilterPillsView(
                    selection: $viewModel.selectedSegment,
                    onSelectionChange: { viewModel.onSegmentFilterChanged() }
                )

                ScrollView {
                    listContent
                        .padding(.horizontal, 12)
                        .padding(.top, 4)
                        .padding(.bottom, 8)
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)

            if viewModel.showsAddFloatingButton {
                Button {
                    draftJournalText = ""
                    viewModel.isAddJournalPresented = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(Color(red: 0.431, green: 0.420, blue: 0.702))
                        )
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 20)
                .padding(.bottom, 120)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if PatientLanguagePreference.shouldShowNeedToTalkButton() {
                JournalEntryBottomChromeView(
                    showOfflineBanner: viewModel.isOffline,
                    offlineMessage: "no_internet_msg".localized,
                    helpButtonTitle: "Need to talk with someone?".localized,
                    onNeedToTalk: { viewModel.openNeedToTalk() }
                )
                .background(Color.white)
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .sheet(isPresented: $viewModel.isAddJournalPresented) {
            JournalEntryAddJournalSheetView(
                text: $draftJournalText,
                onCancel: {
                    viewModel.isAddJournalPresented = false
                },
                onSave: {
                    viewModel.submitNewJournalEntry(text: draftJournalText)
                    draftJournalText = ""
                }
            )
            .presentationDetents([.medium, .large])
        }
    }

    @ViewBuilder
    private var listContent: some View {
        if viewModel.showsEmptyPlaceholder {
            Text("No data for this date".localized)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 17))
                .foregroundStyle(Color(uiColor: UIColor(named: "medicationscelldefaulttextcolor") ?? .gray))
                .frame(maxWidth: .infinity)
                .padding(.top, 48)
        } else {
            switch viewModel.selectedSegment {
            case .questionnaire:
                LazyVStack(spacing: 14) {
                    ForEach(viewModel.quizRows) { row in
                        JournalEntryQuizCardView(row: row)
                    }
                }
            case .diary:
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.dailySections) { section in
                        Text(section.headerText)
                            .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                            .foregroundStyle(Color.black)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(section.rows) { row in
                            let expanded = viewModel.expandedRowIDs.contains(row.id)
                            JournalEntryExpandableJournalRowView(
                                mode: .daily,
                                titleText: row.timeText,
                                collapsedSubtitle: row.bodyText,
                                expandedBody: row.bodyText,
                                bulletLines: [],
                                isExpanded: expanded,
                                onToggle: { viewModel.toggleExpanded(rowID: row.id) }
                            )
                        }
                    }
                }
            case .discovery:
                LazyVStack(spacing: 14) {
                    ForEach(viewModel.discoveryRows) { row in
                        let expanded = viewModel.expandedRowIDs.contains(row.id)
                        JournalEntryExpandableJournalRowView(
                            mode: .discovery,
                            titleText: row.dateText,
                            collapsedSubtitle: row.bodyPreview,
                            expandedBody: row.entryTitle,
                            bulletLines: row.bulletLines,
                            isExpanded: expanded,
                            onToggle: { viewModel.toggleExpanded(rowID: row.id) }
                        )
                    }
                }
            }
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Journal entry — questionnaire") {
    let vm = JournalEntryViewModel()
    vm.applyPreviewState(
        segment: .questionnaire,
        quiz: [
            JournalQuizRowPresentation(
                id: "a",
                sectionTitle: "PHQ-9",
                dateTimeText: "05/15/2026 | 07:22 PM",
                score: 17,
                totalScore: 30
            ),
            JournalQuizRowPresentation(
                id: "b",
                sectionTitle: "CAGE-AID",
                dateTimeText: "05/14/2026 | 06:10 PM",
                score: 2,
                totalScore: 4
            ),
        ],
        daily: [],
        discovery: []
    )
    return JournalEntryView(viewModel: vm)
}
#endif
