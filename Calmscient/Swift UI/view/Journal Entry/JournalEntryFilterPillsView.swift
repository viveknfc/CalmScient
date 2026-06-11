//
//  JournalEntryFilterPillsView.swift
//  Calmscient
//
//  Three-way filter control (questionnaire / diary / discovery).
//
//  Vivek
//  18 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct JournalEntryFilterPillsView: View {

    @Binding var selection: JournalEntrySegment
    var onSelectionChange: () -> Void = {}

    private let purple = Color(red: 0.431, green: 0.420, blue: 0.702)
    private let lavenderBorder = Color(red: 0.910, green: 0.906, blue: 0.957)
    private let pillHeight: CGFloat = 40

    var body: some View {
        HStack(spacing: 8) {
            pill(.questionnaire, title: "Quiz".localized)
            pill(.diary, title: "filter_diary_journal".localized)
            pill(.discovery, title: "filter_discovery_exercise".localized)
        }
        .frame(height: pillHeight)
    }

    private func pill(_ segment: JournalEntrySegment, title: String) -> some View {
        let isOn = selection == segment
        return Button {
            selection = segment
            onSelectionChange()
        } label: {
            Text(title)
                .font(LoginDesignSystem.Typography.lexendRegular(size: 11))
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .foregroundStyle(isOn ? Color.white : Color.black)
                .padding(.horizontal, 6)
                .frame(maxWidth: .infinity, minHeight: pillHeight, maxHeight: pillHeight)
                .background(
                    Capsule()
                        .fill(isOn ? purple : Color.clear)
                )
                .overlay(
                    Capsule()
                        .stroke(isOn ? lavenderBorder : Color.black.opacity(0.35), lineWidth: isOn ? 2 : 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Filter pills") {
    JournalEntryFilterPillsView(selection: .constant(.questionnaire), onSelectionChange: {})
        .padding()
}
#endif
