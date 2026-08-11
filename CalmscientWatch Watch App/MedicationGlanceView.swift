//
//  MedicationGlanceView.swift
//  CalmscientWatch Watch App
//
//  Shows the medications synced from the iPhone with their next dose time.
//
//  11 August 2026
//

import SwiftUI

struct MedicationGlanceView: View {

    @EnvironmentObject private var connectivity: WatchConnectivityManager

    var body: some View {
        Group {
            if connectivity.medications.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "pills")
                        .font(.system(size: 34))
                        .foregroundStyle(.secondary)
                    Text("No medications synced yet")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .padding()
            } else {
                List(connectivity.medications) { med in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(med.name).font(.headline)
                        if !med.dosage.isEmpty {
                            Text(med.dosage)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        if let date = med.nextDoseDate {
                            Text(date, style: .time)
                                .font(.caption2)
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                }
            }
        }
        .navigationTitle("Medications")
    }
}

#Preview {
    MedicationGlanceView()
        .environmentObject(WatchConnectivityManager.shared)
}
