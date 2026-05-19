//
//  GlossaryTermCardView.swift
//  Calmscient
//
//  Expandable glossary term card (parity with `glossyTableCellTableViewCell`).
//
//  Vivek
//  19 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct GlossaryTermCardView: View {

    private static let expandAnimation = Animation.easeInOut(duration: 0.25)

    let term: GlossaryTermRowPresentation
    let isExpanded: Bool
    let onToggle: () -> Void

    private let titleColor = Color("medicationscelldefaulttextcolor")
    private let letterColor = Color("barColor5")
    private let cardBackground = Color(uiColor: .tertiarySystemGroupedBackground)
    private let summaryColor = Color(white: 0.67)
    private let letterBackground = Color(red: 0.878, green: 0.878, blue: 0.878)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(Self.expandAnimation) {
                    onToggle()
                }
            } label: {
                HStack(alignment: .center, spacing: 15) {
                    Text(term.letterInitial)
                        .font(LoginDesignSystem.Typography.lexendRegular(size: 16))
                        .foregroundStyle(letterColor)
                        .frame(width: 42, height: 42)
                        .background(Circle().fill(letterBackground))

                    Text(term.title)
                        .font(LoginDesignSystem.Typography.lexendRegular(size: 16))
                        .foregroundStyle(titleColor)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    expansionIcon
                }
                .frame(minHeight: 55)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                Text(term.summary)
                    .font(.system(size: 13))
                    .foregroundStyle(summaryColor)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                    .padding(.top, 5)
                    .padding(.bottom, 5)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity
                        )
                    )
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .animation(Self.expandAnimation, value: isExpanded)
    }

    @ViewBuilder
    private var expansionIcon: some View {
        let imageName = isExpanded ? "cellCollapse" : "cellExpansion"
        if let image = UIImage(named: imageName) {
            Image(uiImage: image)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                .animation(Self.expandAnimation, value: isExpanded)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Collapsed term") {
    let term = GlossaryTermRowPresentation(index: 2)
    return GlossaryTermCardView(term: term, isExpanded: false, onToggle: {})
        .padding(.horizontal, 10)
}

@available(iOS 16.0, *)
#Preview("Expanded term") {
    let term = GlossaryTermRowPresentation(index: 1)
    return GlossaryTermCardView(term: term, isExpanded: true, onToggle: {})
        .padding(.horizontal, 10)
}
#endif
