//
//  JournalEntrySearchBarView.swift
//  Calmscient
//
//  Search field and calendar affordance for journal entry hub.
//
//  Vivek
//  18 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct JournalEntrySearchBarView: View {

    @Binding var text: String
    var placeholder: String
    var onCalendarTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                if text.isEmpty {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.gray.opacity(0.7))
                }
                TextField(placeholder, text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color(UIColor.lightGray), lineWidth: 1)
                    .background(RoundedRectangle(cornerRadius: 18).fill(Color.white))
            )

            Button(action: onCalendarTap) {
                Image(systemName: "calendar")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color(red: 0.431, green: 0.420, blue: 0.702))
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.white))
            }
            .buttonStyle(.plain)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Search bar") {
    JournalEntrySearchBarView(
        text: .constant(""),
        placeholder: "search_placeholder".localized,
        onCalendarTap: {}
    )
    .padding()
}
#endif
