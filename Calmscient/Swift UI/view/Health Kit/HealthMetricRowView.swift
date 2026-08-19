//
//  HealthMetricRowView.swift
//  Calmscient
//
//  Created by NFC Solutions on 12/08/26.
//

import SwiftUI

// MARK: - Row (one metric: icon + title + latest value)

@available(iOS 16.0, *)
struct HealthMetricRowView: View {

    let row: HealthMetricRowPresentation
    var onToggleFavorite: (String) -> Void = { _ in }
    var onTap: (String) -> Void = { _ in }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 36, height: 36)
                Image(systemName: row.iconName)          // metric icons are SF Symbols
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.pink)
            }

            Text(row.title)
                .font(.system(size: 14))
                .foregroundStyle(.primary)

            Spacer()

            Text(row.valueText)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
            
            Button {                                       // NEW
                onToggleFavorite(row.id)
            } label: {
                Image(systemName: row.isFavorite ? "star.fill" : "star")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(row.isFavorite ? Color.yellow : Color.secondary)
            }
            .buttonStyle(.plain)
            .frame(width: 28, height: 28)
            .contentShape(Rectangle())
            
            Image(systemName: "chevron.right")             // NEW
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .contentShape(Rectangle())                   // NEW
        .onTapGesture { onTap(row.id) }
    }
}


#if DEBUG
@available(iOS 16.0, *)
struct HealthMetricRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            HealthMetricRowView(
                row: HealthMetricRowPresentation(
                    metric: HealthMetric.metric(for: "heart_rate")!,
                    latest: HealthLatestValue(value: 72, displayText: "72 bpm"),
                    isFavorite: true))

            HealthMetricRowView(
                row: HealthMetricRowPresentation(
                    metric: HealthMetric.metric(for: "steps")!,
                    latest: HealthLatestValue(value: nil, displayText: "--"),
                    isFavorite: false))
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .previewLayout(.sizeThatFits)
    }
}
#endif
