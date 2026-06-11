//
//  JournalEntryExpandableJournalRowView.swift
//  Calmscient
//
//  Collapsible row for daily journal and discovery exercise entries.
//
//  Vivek
//  18 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct JournalEntryExpandableJournalRowView: View {

    enum Mode {
        case daily
        case discovery
    }

    let mode: Mode
    let titleText: String
    let collapsedSubtitle: String
    let expandedBody: String
    let bulletLines: [String]
    let isExpanded: Bool
    let onToggle: () -> Void

    private let purple = Color(red: 0.431, green: 0.420, blue: 0.702)

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.25)) {
                onToggle()
            }
        }) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(titleText)
                        .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                        .foregroundStyle(Color.black)
                    
                    Spacer()
                    
                    let imageName = isExpanded ? "cellCollapse" : "cellExpansion"
                    
                    Image(imageName)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.easeInOut(duration: 0.25), value: isExpanded)

                }

                if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Text(expandedBody)
                        .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                        .foregroundStyle(Color.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if mode == .discovery && !bulletLines.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(Array(bulletLines.enumerated()), id: \.offset) { _, line in
                                Text("•  \(line)")
                                    .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                                    .foregroundStyle(Color.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
                } else {
                    Text(collapsedSubtitle)
                        .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                        .foregroundStyle(Color.black.opacity(0.85))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .transition(.opacity)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardSurface)
        }
        .buttonStyle(.plain)
    }

    private var cardSurface: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color(UIColor.systemGray5), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Expandable daily") {
    JournalEntryExpandableJournalRowView(
        mode: .daily,
        titleText: "07:22 PM",
        collapsedSubtitle: "Short journal preview…",
        expandedBody: "Full journal text goes here for the selected day.",
        bulletLines: [],
        isExpanded: false,
        onToggle: {}
    )
    .padding()
}

@available(iOS 16.0, *)
#Preview("Expandable discovery expanded") {
    JournalEntryExpandableJournalRowView(
        mode: .discovery,
        titleText: "05/12/2026",
        collapsedSubtitle: "Moderate drinking",
        expandedBody: "Moderate drinking",
        bulletLines: ["First bullet detail", "Second bullet detail"],
        isExpanded: true,
        onToggle: {}
    )
    .padding()
}
#endif
