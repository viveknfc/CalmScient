//
//  PhoneConnectivityManager.swift
//  Calmscient
//
//  iOS side of the phone <-> watch bridge. Pushes the medication list to the
//  watch and receives mood check-ins / mindful sessions logged on the wrist.
//
//  11 August 2026
//

import Foundation
import WatchConnectivity

@available(iOS 16.0, *)
final class PhoneConnectivityManager: NSObject, ObservableObject {

    static let shared = PhoneConnectivityManager()

    /// Latest mood check-in received from the watch (for the UI to observe).
    @Published private(set) var lastMoodCheckIn: WearableMoodCheckIn?

    /// Latest health snapshot received from the watch (for the UI to observe).
    @Published private(set) var lastHealthSnapshot: WearableHealthSnapshot?

    /// Called whenever a mood check-in arrives from the watch. Wire this up to
    /// persist to the backend / day-feedback flow.
    var onMoodCheckIn: ((WearableMoodCheckIn) -> Void)?

    /// Called whenever a mindful session finishes on the watch.
    var onMindfulSession: ((WearableMindfulSession) -> Void)?

    /// Called whenever a health snapshot arrives from the watch.
    var onHealthSnapshot: ((WearableHealthSnapshot) -> Void)?

    private var session: WCSession? {
        WCSession.isSupported() ? WCSession.default : nil
    }

    private override init() {
        super.init()
    }

    /// Call once early in app startup (e.g. AppDelegate `didFinishLaunching`).
    func activate() {
        guard let session else { return }
        session.delegate = self
        session.activate()
    }

    // MARK: - Phone -> Watch

    /// Sends the current medications to the watch via `updateApplicationContext`,
    /// which delivers the latest snapshot even if the watch app is not running.
    func syncMedications(_ medications: [WearableMedication]) {
        guard let session, session.activationState == .activated else { return }
        let list = WearableMedicationList(medications: medications, updatedAt: Date().timeIntervalSince1970)
        let context = WearableEnvelope.encode(.medications, list)
        do {
            try session.updateApplicationContext(context)
        } catch {
            print("Failed to update watch application context: \(error.localizedDescription)")
        }
    }
}

// MARK: - WCSessionDelegate

@available(iOS 16.0, *)
extension PhoneConnectivityManager: WCSessionDelegate {

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        if let error {
            print("WCSession activation error: \(error.localizedDescription)")
        }
    }

    // Required stubs on iOS for supporting multiple paired watches.
    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        // Re-activate for the newly paired watch.
        session.activate()
    }

    // Interactive messages (watch app in foreground).
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        handle(message)
    }

    // Background transfers (watch app not running).
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        handle(userInfo)
    }

    private func handle(_ message: [String: Any]) {
        guard let kind = WearableEnvelope.kind(of: message) else { return }
        switch kind {
        case .moodCheckIn:
            if let checkIn = WearableEnvelope.decode(WearableMoodCheckIn.self, from: message) {
                DispatchQueue.main.async {
                    self.lastMoodCheckIn = checkIn
                    self.onMoodCheckIn?(checkIn)
                }
            }
        case .mindfulSession:
            if let mindful = WearableEnvelope.decode(WearableMindfulSession.self, from: message) {
                DispatchQueue.main.async { self.onMindfulSession?(mindful) }
            }
        case .healthSnapshot:
            if let snapshot = WearableEnvelope.decode(WearableHealthSnapshot.self, from: message) {
                // Print the object we received from the watch.
                print("⌚→📱 [Watch Health] Received snapshot capturedAt=\(snapshot.capturedDate)")
                for (key, value) in snapshot.values.sorted(by: { $0.key < $1.key }) {
                    print("    • \(key) = \(value)")
                }
                DispatchQueue.main.async {
                    self.lastHealthSnapshot = snapshot
                    self.onHealthSnapshot?(snapshot)
                }
            }
        case .medications:
            break // Phone is the source of truth; ignore inbound.
        }
    }
}
