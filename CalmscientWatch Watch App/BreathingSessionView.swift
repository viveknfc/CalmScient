//
//  BreathingSessionView.swift
//  CalmscientWatch Watch App
//
//  A short guided breathing session. On completion the elapsed minutes are
//  written to HealthKit as a mindful session and reported to the iPhone.
//
//  11 August 2026
//

import SwiftUI

struct BreathingSessionView: View {

    @EnvironmentObject private var connectivity: WatchConnectivityManager
    @Environment(\.dismiss) private var dismiss

    /// Session length options in minutes.
    private let durations = [1, 3, 5]

    @State private var isRunning = false
    @State private var startDate: Date?
    @State private var remaining = 0
    @State private var scale: CGFloat = 0.6
    @State private var timer: Timer?

    var body: some View {
        Group {
            if isRunning {
                runningView
            } else {
                pickerView
            }
        }
        .navigationTitle("Breathe")
        .onDisappear { timer?.invalidate() }
    }

    private var pickerView: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("Choose a length")
                    .font(.headline)
                ForEach(durations, id: \.self) { minutes in
                    Button {
                        start(minutes: minutes)
                    } label: {
                        Text("\(minutes) min")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    private var runningView: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(Color.accentColor.opacity(0.6))
                .frame(width: 90, height: 90)
                .scaleEffect(scale)
                .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: scale)
            Text(timeString(remaining))
                .font(.title3.monospacedDigit())
            Button("Stop") { finish() }
                .buttonStyle(.bordered)
        }
        .onAppear { scale = 1.0 }
    }

    private func start(minutes: Int) {
        startDate = Date()
        remaining = minutes * 60
        isRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remaining > 0 {
                remaining -= 1
            } else {
                finish()
            }
        }
    }

    private func finish() {
        timer?.invalidate()
        timer = nil
        guard let startDate else { dismiss(); return }
        let end = Date()
        let minutes = max(1, Int(end.timeIntervalSince(startDate) / 60.0))

        Task {
            // Request Health access on demand, right before writing the session.
            await WatchHealthKitManager.shared.requestAuthorization()
            await WatchHealthKitManager.shared.saveMindfulSession(start: startDate, end: end)
            let session = WearableMindfulSession(
                minutes: minutes,
                startedAt: startDate.timeIntervalSince1970,
                endedAt: end.timeIntervalSince1970
            )
            connectivity.sendMindfulSession(session)
        }

        isRunning = false
        dismiss()
    }

    private func timeString(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

#Preview {
    BreathingSessionView()
        .environmentObject(WatchConnectivityManager.shared)
}
