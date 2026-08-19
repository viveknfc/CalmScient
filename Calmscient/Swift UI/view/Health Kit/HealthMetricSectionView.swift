//
//  HealthMetricSectionView.swift
//  Calmscient
//
//  Created by NFC Solutions on 12/08/26.
//

import SwiftUI

// MARK: - Section (one category block: header + its rows)

@available(iOS 16.0, *)
struct HealthMetricSectionView: View {

    let section: HealthMetricSectionPresentation
    var onToggleFavorite: (String) -> Void = { _ in }
    var onTap: (String) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(section.title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            VStack(spacing: 10) {
                ForEach(section.rows) { row in
                    HealthMetricRowView(row: row, onToggleFavorite: onToggleFavorite, onTap: onTap)
                }
            }
        }
    }
}


#if DEBUG
@available(iOS 16.0, *)
struct HealthMetricSectionView_Previews: PreviewProvider {
    static var previews: some View {
        func row(_ id: String, _ text: String, fav: Bool = false) -> HealthMetricRowPresentation {
            HealthMetricRowPresentation(
                metric: HealthMetric.metric(for: id)!,
                latest: HealthLatestValue(value: nil, displayText: text),
                isFavorite: fav)
        }
        return HealthMetricSectionView(
            section: HealthMetricSectionPresentation(
                id: "Vitals", title: "Vitals",
                rows: [row("heart_rate", "72 bpm", fav: true),
                       row("spo2", "98 %"),
                       row("respiratory_rate", "16 breaths/min"),
                       row("blood_pressure", "120/80 mmHg")]))
        .padding()
        .background(Color(.systemGroupedBackground))
        .previewLayout(.sizeThatFits)
    }
}
#endif
