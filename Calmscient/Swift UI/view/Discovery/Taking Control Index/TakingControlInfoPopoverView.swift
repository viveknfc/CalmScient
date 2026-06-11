//
//  TakingControlInfoPopoverView.swift
//  Calmscient
//
//  Legend popover for calendar event colors on the Drinking tab.
//
//  Vivek
//  20 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct TakingControlInfoPopoverView: View {

    let items: [TakingControlInfoLegendItem]
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                Button(action: onClose) {
                    if let ui = UIImage(named: "closeIcon") {
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.secondary)
                    }
                }
                .buttonStyle(.plain)
            }

            ForEach(items) { item in
                HStack(spacing: 10) {
                    Circle()
                        .fill(item.dotColor)
                        .frame(width: 12, height: 12)
                    Text(item.title)
                        .font(LoginDesignSystem.Typography.lexendRegular(size: 15))
                        .foregroundStyle(Color.primary)
                }
            }
        }
        .padding(16)
        .frame(width: 300, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.18), radius: 6, x: 0, y: 3)
        )
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Info popover") {
    TakingControlInfoPopoverView(
        items: TakingControlIndexPresentation.drinkingInfoLegend(),
        onClose: {}
    )
    .padding()
}
#endif
