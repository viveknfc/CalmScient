//
//  NeedToTalkPresentation.swift
//  Calmscient
//
//  Presentation models for the emergency resources screen
//  (parity with legacy `NeedToTalkViewController`).
//

import Foundation

/// Provider block shown in the header card (`providerDetails` in the API payload).
struct NeedToTalkProviderPresentation {
    var name: String = ""
    var location: String = ""
    var phoneNumber: String = ""

    /// `tel://` URL built from the digits of `phoneNumber`
    /// (parity with `callPhoneNumber()`).
    var callURL: URL? {
        let digits = phoneNumber.filter { $0.isNumber }
        guard !digits.isEmpty else { return nil }
        return URL(string: "tel://\(digits)")
    }
}

/// One row of `needToTalkWithSomeOne`.
struct NeedToTalkRowPresentation: Identifiable {
    let id: Int
    let title: String
    let content: String?
    let learnMoreURL: String?
}

enum NeedToTalkPresentation {

    /// Crisis contacts hard-linked in the legacy `links` dictionary. Kept exactly:
    /// 988 dials, the two short codes open Messages.
    static let crisisLinks: [String: String] = [
        "988": "tel://988",
        "741741": "sms:741741",
        "678678": "sms:678678",
    ]

    static let navigationTitleKey = "Emergency resources"
    static let noTitleKey = "No title available"
    static let noContentKey = "No content available"
    static let learnMoreKey = "Learn more"
}
