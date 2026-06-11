//
//  ProgressOnCourseWorkProgressBarView.swift
//  Calmscient
//
//  Horizontal progress bar with min/max percentage labels.
//
//  Vivek
//  18 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ProgressOnCourseWorkProgressBarView: View {

    let progress: Float
    let leadingLabel: String
    let trailingLabel: String

    private let trackColor = Color(red: 0.90, green: 0.90, blue: 0.92)
    private let fillColor = Color(red: 0.431, green: 0.420, blue: 0.702)
    private let leadingLabelColor = Color("blueAndWhite")
    private let trailingLabelColor = Color("424242Color")

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(trackColor)

                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(fillColor)
                        .frame(width: geometry.size.width * CGFloat(clampedProgress))
                }
            }
            .frame(height: 12)

            HStack {
                Text(leadingLabel)
                    .font(LoginDesignSystem.Typography.lexendMedium(size: 15))
                    .foregroundStyle(leadingLabelColor)

                Spacer()

                Text(trailingLabel)
                    .font(LoginDesignSystem.Typography.lexendMedium(size: 15))
                    .foregroundStyle(trailingLabelColor)
            }
        }
    }

    private var clampedProgress: Float {
        min(max(progress, 0), 1)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Progress bar") {
    ProgressOnCourseWorkProgressBarView(
        progress: 0.16,
        leadingLabel: "16.0%",
        trailingLabel: "100%"
    )
    .padding()
}
#endif
