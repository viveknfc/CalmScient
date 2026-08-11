//
//  WatchConnectivityManager.swift
//  CalmscientWatch Watch App
//
//  Watch side of the phone <-> watch bridge. Receives the medication list
//  and sends mood check-ins / mindful sessions back to the iPhone.
//
//  11 August 2026
//

import Foundation
import WatchConnectivity

final class WatchConnectivityManager: NSObject, ObservableObject {

    static let shared = WatchConnectivityManager()

    /// Medications pushed from the phone (observed by the glance view).
    @Published private(set) var medications: [WearableMedication] = []

    private var session: WCSession? {
        WCSession.isSupported() ? WCSession.default : nil
    }

    private override init() {
        super.init()
    }

    /// Activate the session. Call once at app launch.
    func activate() {
        guard let session else { return }
        session.delegate = self
        session.activate()
    }

    // MARK: - Watch -> Phone

    func sendMoodCheckIn(_ checkIn: WearableMoodCheckIn) {
        send(WearableEnvelope.encode(.moodCheckIn, checkIn))
    }

    func sendMindfulSession(_ session: WearableMindfulSession) {
        send(WearableEnvelope.encode(.mindfulSession, session))
    }

    func sendHealthSnapshot(_ snapshot: WearableHealthSnapshot) {
        print("⌚ [Watch Health] Sending snapshot: \(snapshot.values) capturedAt=\(snapshot.capturedDate)")
        send(WearableEnvelope.encode(.healthSnapshot, snapshot))
    }

    /// Sends interactively when reachable; otherwise queues a guaranteed
    /// background transfer so nothing is lost when the phone is asleep.
    private func send(_ message: [String: Any]) {
        guard let session, session.activationState == .activated else { return }
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil) { [weak self] _ in
                self?.session?.transferUserInfo(message)
            }
        } else {
            session.transferUserInfo(message)
        }
    }

    // MARK: - Phone -> Watch

    private func applyContext(_ context: [String: Any]) {
        guard WearableEnvelope.kind(of: context) == .medications,
              let list = WearableEnvelope.decode(WearableMedicationList.self, from: context) else { return }
        DispatchQueue.main.async {
            self.medications = list.medications
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        if let error {
            print("WCSession activation error: \(error.localizedDescription)")
            return
        }
        // Pick up whatever the phone last pushed while we were away.
        applyContext(session.receivedApplicationContext)
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        applyContext(applicationContext)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        applyContext(message)
    }
}
