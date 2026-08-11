//
//  HealthMetricDetailView.swift
//  Calmscient
//
//  Per-metric analytics screen: a Daily/Weekly/Monthly/Yearly picker and a
//  Swift Charts plot of the values read from HealthKit.
//
//  11 August 2026
//

import SwiftUI
import Charts

@available(iOS 16.0, *)
struct HealthMetricDetailView: View {

    @ObservedObject var viewModel: HealthMetricDetailViewModel

    var body: some View {
        VStack(spacing: 16) {
            rangePicker

            header

            chart
                .frame(height: 260)
                .padding(.horizontal, 4)

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Color(.systemGroupedBackground))
        .onAppear { viewModel.onAppear() }
    }

    private var rangePicker: some View {
        Picker("Range", selection: $viewModel.range) {
            ForEach(TrendRange.allCases) { range in
                Text(range.title).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }

    private var header: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(viewModel.metric.tint.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: viewModel.metric.systemImage)
                    .foregroundColor(viewModel.metric.tint)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.metric.title)
                    .font(.system(size: 17, weight: .semibold))
                Text(viewModel.summaryText)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    private var chart: some View {
        if viewModel.isLoading {
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.points.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 30))
                    .foregroundColor(.secondary)
                Text("No \(viewModel.metric.title.lowercased()) data for this range.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        } else {
            Chart(viewModel.points) { point in
                if viewModel.usesBars {
                    BarMark(
                        x: .value("Date", point.date),
                        y: .value(viewModel.metric.title, point.value)
                    )
                    .foregroundStyle(viewModel.metric.tint.gradient)
                } else {
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value(viewModel.metric.title, point.value)
                    )
                    .foregroundStyle(viewModel.metric.tint)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value(viewModel.metric.title, point.value)
                    )
                    .foregroundStyle(viewModel.metric.tint.opacity(0.12))
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}
