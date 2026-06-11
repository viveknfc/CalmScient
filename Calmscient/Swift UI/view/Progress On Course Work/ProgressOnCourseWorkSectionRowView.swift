//
//  ProgressOnCourseWorkSectionRowView.swift
//  Calmscient
//
//  Expandable course section row with sub-section completion list.
//
//  Vivek
//  18 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ProgressOnCourseWorkSectionRowView: View {

    let section: ProgressOnCourseWorkSectionPresentation
    let onToggle: () -> Void

    private let titleColor = Color("424242Color")
    private let cardBackground = Color("AppViewContentColor")

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    onToggle()
                }
            }) {
                HStack(alignment: .top, spacing: 8) {
                    Text(section.title)
                        .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                        .foregroundStyle(titleColor)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(section.titlePercentageText)
                        .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                        .foregroundStyle(titleColor)

                    expansionIcon
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if section.isExpanded {
                ForEach(section.subsections) { subsection in
                    HStack(alignment: .top, spacing: 8) {
                        Text(subsection.title)
                            .font(.system(size: 14))
                            .foregroundStyle(titleColor)
                            .multilineTextAlignment(.leading)
                            .padding(.leading, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(subsection.percentageText)
                            .font(LoginDesignSystem.Typography.lexendLight(size: 12))
                            .foregroundStyle(titleColor)
                    }
                }
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity
                    )
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(cardBackground)
                .progressOnCourseWorkCardShadow()
        )

    }

    @ViewBuilder
    private var expansionIcon: some View {
        let imageName = section.isExpanded ? "cellCollapse" : "cellExpansion"
        if let image = UIImage(named: imageName) {
            Image(uiImage: image)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18) // reduced size
                .padding(.top, 2)
                .rotationEffect(.degrees(section.isExpanded ? 180 : 0))
                .animation(.easeInOut(duration: 0.25), value: section.isExpanded)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Collapsed section") {
    let section = CourseProgressPresentationPreviewData.detailSections().first!
    return ProgressOnCourseWorkSectionRowView(section: section, onToggle: {})
        .padding()
}

@available(iOS 16.0, *)
#Preview("Expanded section") {
    var section = CourseProgressPresentationPreviewData.detailSections().first!
    section.isExpanded = true
    return ProgressOnCourseWorkSectionRowView(section: section, onToggle: {})
        .padding()
}
#endif
