//
//  PatientLanguagePreference.swift
//  Calmscient
//
//  Display-name–centric language helpers (aligned with `getPatientLanguages` / `languageName`).
//

import Foundation

enum PatientLanguagePreference {

    static let displayNameUserDefaultsKey = "SelectedLanguageDisplayName"

    static func normalizedDisplayName(_ raw: String) -> String {
        raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    /// Maps backend `languageId` to display names matching `getPatientLanguages` when only an id is known (e.g. login).
    static func displayName(forLanguageId id: Int) -> String {
        switch id {
        case 2:
            return "Spanish"
        case 6:
            return "Japanese"
        case 7, 9:
            return "ASL"
        default:
            return "English"
        }
    }

    /// Bundle / `Bundle.setLanguage` codes; no dedicated ASL bundle — follow prior id-based behavior (English resources).
    static func bundleLocaleCode(forDisplayName displayName: String) -> String {
        switch normalizedDisplayName(displayName) {
        case "spanish":
            return "es"
        case "japanese":
            return "ja"
        case "asl":
            return "en"
        default:
            return "en"
        }
    }

    static func currentDisplayName() -> String {
        if let stored = UserDefaults.standard.string(forKey: displayNameUserDefaultsKey),
           !stored.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return stored
        }
        let rawId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
        let id = rawId == 0 ? 1 : rawId
        return displayName(forLanguageId: id)
    }

    /// Used for image assets that were keyed off `SelectedLanguageID == 1` (English vs Spanish toggle art).
    static func isEnglishForLocalizedAssets() -> Bool {
        normalizedDisplayName(currentDisplayName()) == "english"
    }

    /// Emergency “Need to talk with someone?” entry points are hidden for Japanese patients.
    static func shouldShowNeedToTalkButton() -> Bool {
        normalizedDisplayName(currentDisplayName()) != "japanese"
    }

    static func persistLoginLanguage(languageId: Int) {
        let id = languageId == 0 ? 1 : languageId
        UserDefaults.standard.set(id, forKey: "SelectedLanguageID")
        let name = displayName(forLanguageId: id)
        UserDefaults.standard.set(name, forKey: displayNameUserDefaultsKey)
        let code = bundleLocaleCode(forDisplayName: name)
        UserDefaults.standard.set(code, forKey: "appLanguage")
        Bundle.setLanguage(code)
    }

    /// After profile language chip selection; keeps `languageId` for APIs and legacy reads.
    static func persistProfileSelection(canonicalDisplayName: String, languageId: Int) {
        UserDefaults.standard.set(languageId, forKey: "SelectedLanguageID")
        UserDefaults.standard.set(canonicalDisplayName, forKey: displayNameUserDefaultsKey)
        let code = bundleLocaleCode(forDisplayName: canonicalDisplayName)
        UserDefaults.standard.set(code, forKey: "appLanguage")
        Bundle.setLanguage(code)
    }
}
