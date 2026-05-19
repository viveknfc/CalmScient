//
//  CoursesChapterCardView.swift
//  Calmscient
//
//  Horizontal chapter card for a course lesson row.
//
//  Vivek
//  19 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct CoursesChapterCardView: View {

    let chapter: CourseChapterPresentation
    let usesWhiteChapterTitle: Bool
    let onTap: () -> Void

    private let cardSize = CGSize(width: 172, height: 120)

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                chapterImage
                    .frame(width: cardSize.width, height: cardSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))

                Text(chapter.title)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 13))
                    .foregroundStyle(usesWhiteChapterTitle ? Color.white : Color("AppThemeColor"))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .padding(.horizontal, 6)
                    .padding(.bottom, 4)
                    .frame(width: cardSize.width, alignment: .leading)

                if chapter.isCompleted {
                    Image("tickMark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 15)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(.top, 12)
                        .padding(.trailing, 6)
                }
            }
        }
        .buttonStyle(.plain)
        .frame(width: cardSize.width, height: cardSize.height)
    }

    @ViewBuilder
    private var chapterImage: some View {
        if let url = URL(string: chapter.imageURLString), !chapter.imageURLString.isEmpty {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure, .empty:
                    placeholder
                @unknown default:
                    placeholder
                }
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        Rectangle()
            .fill(Color("AppBackGroundColor"))
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Courses chapter card") {
    CoursesChapterCardView(
        chapter: CoursesPresentationPreviewData.sampleLessons[0].chapters[0],
        usesWhiteChapterTitle: true,
        onTap: {}
    )
    .padding()
    .background(Color("AppBackGroundColor"))
}
#endif
