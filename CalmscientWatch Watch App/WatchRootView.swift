//
//  WatchRootView.swift
//  CalmscientWatch Watch App
//
//  Home screen listing the three wrist features: mood check-in,
//  a breathing session, and the medication glance.
//
//  11 August 2026
//

import SwiftUI

struct WatchRootView: View {

    @EnvironmentObject private var connectivity: WatchConnectivityManager
    @State private var syncStatus: String?

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    MoodCheckInView()
                } label: {
                    Label("Mood Check-In", systemImage: "face.smiling")
                }

                NavigationLink {
                    BreathingSessionView()
                } label: {
                    Label("Breathe", systemImage: "wind")
                }

                NavigationLink {
                    MedicationGlanceView()
                } label: {
                    Label("Medications", systemImage: "pills.fill")
                }

                Button {
                    syncHealth()
                } label: {
                    Label(syncStatus ?? "Sync Health", systemImage: "heart.text.square.fill")
                }
            }
            .navigationTitle("CalmScient")
        }
        .onAppear { syncHealth() }
    }

    /// Reads the watch's health metrics and sends them to the phone.
    private func syncHealth() {
        syncStatus = "Syncing…"
        Task {
            let snapshot = await WatchHealthKitManager.shared.captureSnapshot()
            connectivity.sendHealthSnapshot(snapshot)
            syncStatus = "Synced \(snapshot.values.count) metrics"
        }
    }
}

#Preview {
    WatchRootView()
        .environmentObject(WatchConnectivityManager.shared)
}
