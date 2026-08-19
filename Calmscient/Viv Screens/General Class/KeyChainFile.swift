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

    static func saveLoginDetailsToUserDefaults(loginDetails: LoginDetails, tokenResponse: TokenResponse) {
        do {
            let loginDetailsData = try JSONEncoder().encode(loginDetails)
            let tokenResponseData = try JSONEncoder().encode(tokenResponse)

            UserDefaults.standard.set(loginDetailsData, forKey: "loginDetails")
            UserDefaults.standard.set(tokenResponseData, forKey: "tokenResponse")
            UserDefaults.standard.synchronize()
        } catch {
            print("Error saving to UserDefaults: \(error)")
        }
    }

    static func retrieveLoginDetailsFromUserDefaults() -> (LoginDetails?, TokenResponse?) {
        do {
            if let loginDetailsData = UserDefaults.standard.data(forKey: "loginDetails"),
               let tokenResponseData = UserDefaults.standard.data(forKey: "tokenResponse") {
                let loginDetails = try JSONDecoder().decode(LoginDetails.self, from: loginDetailsData)
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: tokenResponseData)
                return (loginDetails, tokenResponse)
            }
        } catch {
            print("Error retrieving from UserDefaults: \(error)")
        }
        return (nil, nil)
    }

    static func clearLoginDetailsFromUserDefaults() {
        UserDefaults.standard.removeObject(forKey: "loginDetails")
        UserDefaults.standard.removeObject(forKey: "tokenResponse")
        UserDefaults.standard.synchronize()
        print("UserDefaults cleared for login details and token response")
    }
}

