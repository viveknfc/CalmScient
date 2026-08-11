//
//  HealthMetricsView.swift
//  Calmscient
//
//  Health Metrics dashboard: metrics grouped into 6 categories, each row
//  showing an icon, name, current value and a chevron into its trend screen.
//  Matches the Health Metrics design.
//
//  11 August 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct HealthMetricsView: View {

    @ObservedObject var viewModel: HealthMetricsViewModel

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                if viewModel.authorizationDenied {
                    unavailableBanner
                }
                ForEach(viewModel.sections) { section in
                    sectionView(section)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .overlay(alignment: .top) {
            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 8)
            }
        }
        .onAppear { viewModel.onAppear() }
    }

    // MARK: - Sections

    private func sectionView(_ section: HealthMetricsViewModel.Section) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text(section.category.emoji)
                Text(section.category.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.leading, 4)

            VStack(spacing: 0) {
                ForEach(Array(section.rows.enumerated()), id: \.element.id) { index, row in
                    Button {
                        viewModel.openMetric(row.metric)
                    } label: {
                        MetricRowView(row: row)
                    }
                    .buttonStyle(.plain)

                    if index < section.rows.count - 1 {
                        Divider().padding(.leading, 56)
                    }
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var unavailableBanner: some View {
        Text("Health data isn't available on this device.")
            .font(.footnote)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 8)
    }
}

@available(iOS 16.0, *)
private struct MetricRowView: View {
    let row: HealthMetricsViewModel.Row

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(row.metric.tint.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: row.metric.systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(row.metric.tint)
            }

            Text(row.metric.title)
                .font(.system(size: 16))
                .foregroundColor(.primary)

            Spacer(minLength: 8)

            Text(valueText)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.secondary)

            if row.metric.isHealthKitBacked {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }

    private var valueText: String {
        row.value == "--" ? "--" : "\(row.value) \(row.metric.unit)"
    }
}
