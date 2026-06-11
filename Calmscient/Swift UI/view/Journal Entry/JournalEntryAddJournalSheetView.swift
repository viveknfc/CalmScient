//
//  JournalEntryAddJournalSheetView.swift
//  Calmscient
//
//  Sheet content for creating a daily journal entry (replaces `JournalEntryEditView`).
//
//  Vivek
//  18 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
struct JournalEntryAddJournalSheetView: View {

    // MARK: - Properties

    @Binding var text: String

    let onCancel: () -> Void
    let onSave: () -> Void

    private let maxCharacters = 2000
    private let editorMinHeight: CGFloat = 180

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {

                titleView

                journalEditorView

                characterCountView

                saveButton
            }
            .padding(.horizontal, 16)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                closeToolbarButton
            }
        }
        .onChange(of: text) { newValue in
            limitCharacters(for: newValue)
        }
    }
}

// MARK: - Subviews

@available(iOS 16.0, *)
private extension JournalEntryAddJournalSheetView {

    var titleView: some View {
        Text("journal_edit_title".localized)
            .font(LoginDesignSystem.Typography.lexendRegular(size: 18))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 8)
    }

    var journalEditorView: some View {
        ZStack(alignment: .topLeading) {

            if text.isEmpty {
                placeholderView
            }

            TextEditor(text: $text)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 15))
                .frame(minHeight: editorMinHeight)
                .scrollContentBackground(.hidden)
        }
        .padding(8)
        .background(editorBorderView)
    }

    var placeholderView: some View {
        Text("journal_edit_placeholder".localized)
            .font(LoginDesignSystem.Typography.lexendRegular(size: 15))
            .foregroundStyle(Color.gray.opacity(0.6))
            .padding(.horizontal, 6)
            .padding(.vertical, 10)
    }

    var characterCountView: some View {
        Text(
            String(
                format: "journal_edit_char_count_format".localized,
                min(text.count, maxCharacters)
            )
        )
        .font(LoginDesignSystem.Typography.lexendRegular(size: 12))
        .frame(maxWidth: .infinity, alignment: .trailing)
        .foregroundStyle(.gray)
    }

    var saveButton: some View {
        Button(action: onSave) {
            Text("journal_edit_add_button".localized)
                .font(LoginDesignSystem.Typography.lexendSemiBold(size: 16))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(LoginDesignSystem.ColorName.loginGradient)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 30,
                        style: .continuous
                    )
                )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 30)
    }

    var editorBorderView: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(Color(UIColor.systemGray4), lineWidth: 1)
    }

    var closeToolbarButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: onCancel) {
                Image("closeIcon")
                    .renderingMode(.original)
            }
        }
    }
}

// MARK: - Methods

@available(iOS 16.0, *)
private extension JournalEntryAddJournalSheetView {

    func limitCharacters(for value: String) {
        guard value.count > maxCharacters else { return }
        text = String(value.prefix(maxCharacters))
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Add journal sheet") {
    JournalEntryAddJournalSheetView(
        text: .constant(""),
        onCancel: {},
        onSave: {}
    )
}
#endif
