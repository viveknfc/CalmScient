//
//  HealthSyncDebugScreen.swift
//  Calmscient
//
//  Created by NFC Solutions on 19/08/26.
//

import SwiftUI
import UIKit

/// A read-out of what health sync has actually been doing.
///
/// Deliberately not compiled out of release builds. The runs that matter most are the unattended
/// ones — a 5am wake-up on a tester's phone with no debugger attached — and those only exist in
/// TestFlight. Without a way to read the log on the device there is no way to tell "iOS never woke
/// us" apart from "we woke and the upload failed", and from the backend the two look identical.
///
/// No entry point is wired up. Present it from wherever suits — a long-press on a version label,
/// a hidden row in Settings:
///
///     let vc = HealthSyncDebugHostingController()
///     navigationController?.pushViewController(vc, animated: true)
struct HealthSyncDebugView: View {

    @State private var attempts: [HealthSyncSlotStore.Attempt] = []
    @State private var isSyncing = false

    private static let timestampFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd MMM HH:mm:ss"
        return f
    }()

    var body: some View {
        List {
            Section("Schedule") {
                row("Slot hours", HealthSyncConfiguration.slotHours.map(String.init).joined(separator: ", "))
                row("Current slot", currentSlotDescription)
                row("Last sent slot", HealthSyncSlotStore.shared.lastSentSlotKey ?? "never")
                row("Login bypasses slot", HealthSyncConfiguration.loginSyncBypassesSlotCheck ? "yes" : "no")
            }

            Section("Actions") {
                Button(isSyncing ? "Syncing…" : "Sync now") {
                    isSyncing = true
                    Task {
                        await HealthSyncCoordinator.shared.sync(trigger: .foreground)
                        isSyncing = false
                        reload()
                    }
                }
                .disabled(isSyncing)

                Button("Clear slot state and log", role: .destructive) {
                    HealthSyncSlotStore.shared.reset()
                    reload()
                }
            }

            Section("Recent attempts (newest first)") {
                if attempts.isEmpty {
                    Text("Nothing recorded yet").foregroundStyle(.secondary)
                } else {
                    ForEach(Array(attempts.reversed().enumerated()), id: \.offset) { _, attempt in
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(Self.timestampFormatter.string(from: attempt.at))  ·  \(attempt.trigger)")
                                .font(.footnote.weight(.semibold))
                            Text(attempt.outcome)
                                .font(.footnote)
                                .foregroundStyle(attempt.outcome.hasPrefix("failed") ? Color.red : Color.secondary)
                            if let slotKey = attempt.slotKey {
                                Text("slot \(slotKey)")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .navigationTitle("Health Sync")
        .onAppear(perform: reload)
        .refreshable { reload() }
    }

    private var currentSlotDescription: String {
        guard let slotStart = HealthSyncSlotStore.shared.currentSlotStart() else {
            return "none (grid empty)"
        }
        return "\(Self.timestampFormatter.string(from: slotStart))  ·  \(HealthSyncSlotStore.slotKey(for: slotStart))"
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
            Spacer(minLength: 12)
            Text(value)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }

    private func reload() {
        attempts = HealthSyncSlotStore.shared.attempts()
    }
}

/// UIKit wrapper, matching how the other SwiftUI screens in the app are presented.
final class HealthSyncDebugHostingController: UIHostingController<HealthSyncDebugView> {

    init() {
        super.init(rootView: HealthSyncDebugView())
        // `navigationTitle` inside the SwiftUI view does not reach a UIKit navigation bar when the
        // controller is pushed rather than wrapped in a NavigationStack.
        title = "Health Sync"
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
