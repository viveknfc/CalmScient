//
//  KeyChainFile.swift
//  CalmscientIOS
//
//  Created by NFC User on 06/01/25.
//

import Foundation

struct UserDefaultsHelper {
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

