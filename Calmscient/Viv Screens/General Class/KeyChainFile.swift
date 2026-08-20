//
//  KeyChainFile.swift
//  CalmscientIOS
//
//  Created by NFC User on 06/01/25.
//

import Foundation

struct UserDefaultsHelper {

    static let rememberMeUserDefaultsKey = "rememberMe"

    /// `true` only when the user ticked "Remember Me" on the last successful login.
    /// Single source of truth for "may this session survive an app relaunch?".
    static var isRememberMeEnabled: Bool {
        UserDefaults.standard.integer(forKey: rememberMeUserDefaultsKey) == 1
    }

    static func setRememberMeEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled ? 1 : 0, forKey: rememberMeUserDefaultsKey)
        UserDefaults.standard.synchronize()
    }

    /// Persists the session to disk **only** when Remember Me is on; otherwise makes sure
    /// no stale session is left behind. A session without Remember Me lives in
    /// `ApplicationSharedInfo` (memory) for as long as the process lives and no longer.
    static func persistLoginDetailsIfRemembered(
        loginDetails: LoginDetails,
        tokenResponse: TokenResponse,
        remembered: Bool = UserDefaultsHelper.isRememberMeEnabled
    ) {
        guard remembered else {
            clearLoginDetailsFromUserDefaults()
            return
        }
        saveLoginDetailsToUserDefaults(loginDetails: loginDetails, tokenResponse: tokenResponse)
    }

    // MARK: - Session storage
    //
    // The three functions below keep their original names because every call site in the app
    // uses them, but the session now lives in the Keychain rather than in `UserDefaults`. The
    // move was made because background health sync reads this blob — it holds a refresh token
    // and the patient's identifiers — on a locked device, and a plist in the app's Library
    // directory is the wrong home for that. See `SessionKeychainStore` for the accessibility
    // choice. Nothing about *when* a session is persisted changed.

    private static let loginDetailsAccount = "loginDetails"
    private static let tokenResponseAccount = "tokenResponse"

    static func saveLoginDetailsToUserDefaults(loginDetails: LoginDetails, tokenResponse: TokenResponse) {
        do {
            let loginDetailsData = try JSONEncoder().encode(loginDetails)
            let tokenResponseData = try JSONEncoder().encode(tokenResponse)

            SessionKeychainStore.save(loginDetailsData, for: loginDetailsAccount)
            SessionKeychainStore.save(tokenResponseData, for: tokenResponseAccount)

            // An install that previously wrote the session in the clear should not keep a stale
            // plaintext copy once the Keychain is authoritative.
            removeLegacySessionCopies()
        } catch {
            print("Error saving session: \(error)")
        }
    }

    static func retrieveLoginDetailsFromUserDefaults() -> (LoginDetails?, TokenResponse?) {
        do {
            if let loginDetailsData = SessionKeychainStore.read(loginDetailsAccount),
               let tokenResponseData = SessionKeychainStore.read(tokenResponseAccount) {
                let loginDetails = try JSONDecoder().decode(LoginDetails.self, from: loginDetailsData)
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: tokenResponseData)
                return (loginDetails, tokenResponse)
            }

            // One-time migration for an install that logged in before the session moved to the
            // Keychain. Without it, updating the app would silently sign out every "Remember Me"
            // user. Read the old copy once, re-home it, then drop the plaintext.
            if let loginDetailsData = UserDefaults.standard.data(forKey: loginDetailsAccount),
               let tokenResponseData = UserDefaults.standard.data(forKey: tokenResponseAccount) {
                let loginDetails = try JSONDecoder().decode(LoginDetails.self, from: loginDetailsData)
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: tokenResponseData)

                SessionKeychainStore.save(loginDetailsData, for: loginDetailsAccount)
                SessionKeychainStore.save(tokenResponseData, for: tokenResponseAccount)
                removeLegacySessionCopies()
                print("Session migrated from UserDefaults to Keychain")

                return (loginDetails, tokenResponse)
            }
        } catch {
            print("Error retrieving session: \(error)")
        }
        return (nil, nil)
    }

    static func clearLoginDetailsFromUserDefaults() {
        SessionKeychainStore.delete(loginDetailsAccount)
        SessionKeychainStore.delete(tokenResponseAccount)
        removeLegacySessionCopies()

        // Every logout path in the app funnels through here, so this is the one place that can
        // guarantee background health sync stops the moment the credentials it needs are gone.
        // Left running, its scheduled wake-ups would keep firing with nothing to authenticate —
        // battery spent for no data.
        HealthSyncCoordinator.shared.shutdown(reason: .sessionCleared)

        print("Session cleared (Keychain and any legacy UserDefaults copy)")
    }

    /// Removes the pre-Keychain plaintext session, if this install still has one.
    private static func removeLegacySessionCopies() {
        UserDefaults.standard.removeObject(forKey: loginDetailsAccount)
        UserDefaults.standard.removeObject(forKey: tokenResponseAccount)
        UserDefaults.standard.synchronize()
    }
}
