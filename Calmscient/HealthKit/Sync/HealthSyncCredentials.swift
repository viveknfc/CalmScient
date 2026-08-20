//
//  HealthSyncCredentials.swift
//  Calmscient
//
//  Created by NFC Solutions on 19/08/26.
//

import Foundation

/// The credentials a health-sync upload needs, resolved without depending on UI state.
///
/// The important thing this type does is *not* read `ApplicationSharedInfo` when the app was
/// launched in the background. That singleton is populated by `SceneDelegate` a couple of
/// seconds after a **scene** connects, and a background launch (BGTask, HealthKit observer,
/// silent push) never connects one — so on exactly the wake-ups background sync exists to
/// serve, `ApplicationSharedInfo.shared.loginResponse` and `.tokenResponse` are both nil.
/// Treat that singleton as foreground-only.
struct HealthSyncCredentials {

    let patientId: Int
    let accessToken: String
    let refreshToken: String

    /// Credentials for an **unattended** upload, read straight from persisted storage.
    ///
    /// Gated on Remember Me by design: a user who declined to have their session persisted
    /// gets no background upload either. They are covered instead by the login-time and
    /// screen-open syncs, which use `forForegroundSync()`.
    ///
    /// Returns nil when there is no session that may legitimately be used with nobody present.
    static func current() -> HealthSyncCredentials? {
        guard UserDefaultsHelper.isRememberMeEnabled else {
            return nil
        }
        return fromPersistedSession()
    }

    /// Credentials for an upload happening while the user is present (just logged in, or the
    /// Health Metrics screen is open).
    ///
    /// Prefers the in-memory session and only then falls back to disk, and deliberately does
    /// **not** check Remember Me: for a user who declined it this is the only path that ever
    /// reaches the backend, so refusing here would mean they contribute no data at all.
    static func forForegroundSync() -> HealthSyncCredentials? {
        if let loginDetails = ApplicationSharedInfo.shared.loginResponse,
           let tokenResponse = ApplicationSharedInfo.shared.tokenResponse {
            return HealthSyncCredentials(
                patientId: loginDetails.patientID,
                accessToken: tokenResponse.accessToken,
                refreshToken: tokenResponse.refreshToken
            )
        }
        return fromPersistedSession()
    }

    private static func fromPersistedSession() -> HealthSyncCredentials? {
        let (loginDetails, tokenResponse) = UserDefaultsHelper.retrieveLoginDetailsFromUserDefaults()

        guard let loginDetails = loginDetails, let tokenResponse = tokenResponse else {
            return nil
        }

        return HealthSyncCredentials(
            patientId: loginDetails.patientID,
            accessToken: tokenResponse.accessToken,
            refreshToken: tokenResponse.refreshToken
        )
    }
}
