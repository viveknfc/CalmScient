//
//  WearableMessages.swift
//  Calmscient
//
//  Shared payloads and WatchConnectivity keys used by BOTH the iOS app
//  and the watchOS app. Add this file to both targets in Xcode.
//
//  11 August 2026
//

import Foundation

/// Well-known keys for WatchConnectivity `applicationContext` / `sendMessage`
/// dictionaries. Kept in one place so phone and watch never drift apart.
public enum WearableKey {
    /// Top-level discriminator identifying which payload a message carries.
    public static let kind = "kind"

    /// Payload keys.
    public static let payload = "payload"
}

/// Identifies the kind of message flowing between phone and watch.
public enum WearableMessageKind: String, Codable {
    /// Phone -> Watch: the current set of medications to show on the wrist.
    case medications
    /// Watch -> Phone: a mood check-in the user logged on the watch.
    case moodCheckIn
    /// Watch -> Phone: a mindfulness/breathing session finished on the watch.
    case mindfulSession
    /// Watch -> Phone: a snapshot of health metrics read on the watch.
    case healthSnapshot
}

/// Watch -> Phone: current health metric values read on the watch and sent to
/// the phone. Keys are `HealthMetricType.rawValue`; values are display-ready
/// (already scaled for units, e.g. SpO₂ as 98.0 not 0.98).
public struct WearableHealthSnapshot: Codable {
    public var values: [String: Double]
    public var capturedAt: Double

    public init(values: [String: Double], capturedAt: Double) {
        self.values = values
        self.capturedAt = capturedAt
    }

    public var capturedDate: Date { Date(timeIntervalSince1970: capturedAt) }
}

/// A single medication surfaced on the watch glance.
public struct WearableMedication: Codable, Identifiable, Hashable {
    public var id: String
    public var name: String
    public var dosage: String
    /// Next scheduled time (epoch seconds) if known.
    public var nextDoseAt: Double?

    public init(id: String, name: String, dosage: String, nextDoseAt: Double? = nil) {
        self.id = id
        self.name = name
        self.dosage = dosage
        self.nextDoseAt = nextDoseAt
    }

    public var nextDoseDate: Date? {
        guard let nextDoseAt else { return nil }
        return Date(timeIntervalSince1970: nextDoseAt)
    }
}

/// Phone -> Watch snapshot of the medications list.
public struct WearableMedicationList: Codable {
    public var medications: [WearableMedication]
    public var updatedAt: Double

    public init(medications: [WearableMedication], updatedAt: Double) {
        self.medications = medications
        self.updatedAt = updatedAt
    }
}

/// A mood value the user can pick on the watch. Mirrors the phone's day-feedback scale.
public enum WearableMood: String, Codable, CaseIterable, Identifiable {
    case great
    case good
    case okay
    case low
    case rough

    public var id: String { rawValue }

    /// Emoji shown on the watch face for this mood.
    public var emoji: String {
        switch self {
        case .great: return "😄"
        case .good:  return "🙂"
        case .okay:  return "😐"
        case .low:   return "😔"
        case .rough: return "😣"
        }
    }

    /// Human-readable label.
    public var title: String {
        switch self {
        case .great: return "Great"
        case .good:  return "Good"
        case .okay:  return "Okay"
        case .low:   return "Low"
        case .rough: return "Rough"
        }
    }

    /// 1...5 numeric score (5 = great) for syncing with the phone/backend.
    public var score: Int {
        switch self {
        case .great: return 5
        case .good:  return 4
        case .okay:  return 3
        case .low:   return 2
        case .rough: return 1
        }
    }
}

/// Watch -> Phone: a mood check-in logged on the wrist.
public struct WearableMoodCheckIn: Codable {
    public var mood: WearableMood
    public var loggedAt: Double

    public init(mood: WearableMood, loggedAt: Double) {
        self.mood = mood
        self.loggedAt = loggedAt
    }

    public var loggedDate: Date { Date(timeIntervalSince1970: loggedAt) }
}

/// Watch -> Phone: notification that a mindful session was completed and
/// written to HealthKit on the watch.
public struct WearableMindfulSession: Codable {
    public var minutes: Int
    public var startedAt: Double
    public var endedAt: Double

    public init(minutes: Int, startedAt: Double, endedAt: Double) {
        self.minutes = minutes
        self.startedAt = startedAt
        self.endedAt = endedAt
    }
}

/// Helpers to encode/decode a typed payload into the untyped `[String: Any]`
/// dictionaries WatchConnectivity requires.
public enum WearableEnvelope {
    public static func encode<T: Encodable>(_ kind: WearableMessageKind, _ value: T) -> [String: Any] {
        guard let data = try? JSONEncoder().encode(value) else {
            return [WearableKey.kind: kind.rawValue]
        }
        return [
            WearableKey.kind: kind.rawValue,
            WearableKey.payload: data
        ]
    }

    public static func kind(of message: [String: Any]) -> WearableMessageKind? {
        guard let raw = message[WearableKey.kind] as? String else { return nil }
        return WearableMessageKind(rawValue: raw)
    }

    public static func decode<T: Decodable>(_ type: T.Type, from message: [String: Any]) -> T? {
        guard let data = message[WearableKey.payload] as? Data else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
