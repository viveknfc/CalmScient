//
//  TokenExpiryCheck.swift
//  CalmscientIOS
//
//  Created by NFC User on 13/02/25.
//

import Foundation
import UIKit

class TokenManager{
    
    static let shared = TokenManager()

       private let accessTokenKey = "accessToken"
       private let expiryTimeKey = "tokenExpiry"

       // Save token & expiry time
       func saveTokenData(accessToken: String, expiresIn: Int) {
           let expiryDate = Date().addingTimeInterval(TimeInterval(expiresIn)) // Calculate expiry time
           UserDefaults.standard.set(accessToken, forKey: accessTokenKey)
           UserDefaults.standard.set(expiryDate, forKey: expiryTimeKey)
           UserDefaults.standard.synchronize()
       }
    
    // Check if token is expired
      func isTokenExpired() -> Bool {
          if let expiryDate = UserDefaults.standard.object(forKey: expiryTimeKey) as? Date {
              return Date() >= expiryDate // Expired if current date is past expiry
          }
          return true // Assume expired if expiry date is missing
      }

    /// The refresh token to present to the server: the in-memory session first, the persisted
    /// one as a fallback.
    ///
    /// That fallback is what makes refresh possible at all on a background launch.
    /// `ApplicationSharedInfo` is only filled in by the scene-connect path in `SceneDelegate`,
    /// which never runs when iOS wakes the app for a BGTask or a HealthKit observer — so
    /// reading it alone used to fail with "No refresh token available" every time.
    private func currentRefreshToken() -> String? {
        if let token = ApplicationSharedInfo.shared.tokenResponse?.refreshToken {
            return token
        }
        return UserDefaultsHelper.retrieveLoginDetailsFromUserDefaults().1?.refreshToken
    }
    
    //Refresh API
    func refreshAccessToken(from viewController: UIViewController?, completion: @escaping (Bool) -> Void) {
        guard let refreshToken = currentRefreshToken() else {
            print("No refresh token available")
            completion(false)
            return
        }

        let params: [String: String] = ["refreshToken": refreshToken]
        print("Refreshing access token with params:", params)

        viewController?.view.showToastActivity() // Show loading indicator if viewController is available

        APIService.refreshAPICalling(viewController, params: params, method: "POST", accessToken: "", acces: false, parameterPlacement: "header") { response in
            DispatchQueue.main.async {
                viewController?.view.hideToastActivity() // Hide loading indicator if viewController is available
                let success = self.getresponseforRefreshAPI(response: response)
                completion(success)
            }
        }
    }

    /// Refreshes the access token with no UI attached, for unattended (background) use.
    ///
    /// `refreshAccessToken(from:completion:)` is left exactly as it was — four foreground call
    /// sites rely on its toast behaviour and its hop to the main queue. This variant passes a nil
    /// view controller (both `refreshAPICalling` and `getRequestWithToken` already take an
    /// optional one), skips the toasts, and stays off the main queue so it can run inside the
    /// short window a background wake-up gets.
    @discardableResult
    func refreshAccessTokenHeadless() async -> Bool {
        guard let refreshToken = currentRefreshToken() else {
            print("TokenManager: no refresh token available for headless refresh")
            return false
        }

        let params: [String: String] = ["refreshToken": refreshToken]

        return await withCheckedContinuation { continuation in
            // The callback contract of `getRequestWithToken` is one call, but resuming a
            // continuation twice is a hard crash rather than a warning, so this is guarded.
            var hasResumed = false
            let resumeOnce: (Bool) -> Void = { result in
                guard !hasResumed else { return }
                hasResumed = true
                continuation.resume(returning: result)
            }

            APIService.refreshAPICalling(nil, params: params, method: "POST",
                                         accessToken: "", acces: false,
                                         parameterPlacement: "header") { response in
                resumeOnce(self.getresponseforRefreshAPI(response: response))
            }
        }
    }

    
    func getresponseforRefreshAPI(response:AnyObject)-> Bool {
        
        if let responseString = response as? String {
            print("Response received from refresh API calling is", responseString)
            return false
        } else if let responseDict = response as? [String: Any] {
            do {
                // Convert the dictionary to Data
                let responseData = try JSONSerialization.data(withJSONObject: responseDict, options: [])
                
                // Decode the Data into LoginResponse
                let loginResponse = try JSONDecoder().decode(TokenResponse.self, from: responseData)
                print("Decoded LoginResponse:", loginResponse.scope)
                
                // Store token response
                ApplicationSharedInfo.shared.tokenResponse = loginResponse
                
                saveTokenData(accessToken: loginResponse.accessToken, expiresIn: loginResponse.expiresIn)
                
                // Keycloak rotates the refresh token on every use, so the new one MUST reach
                // storage — otherwise the next wake-up presents a token the server has already
                // invalidated and sync stops for good.
                //
                // This used to be gated on `ApplicationSharedInfo.shared.loginResponse` alone,
                // which is never populated on a background launch: the rotated token was silently
                // dropped there while working perfectly in the foreground. Falling back to the
                // persisted login details fixes that without weakening the "no disk write unless
                // Remember Me" rule, which `persistLoginDetailsIfRemembered` still enforces.
                let loginDetailsForPersistence = ApplicationSharedInfo.shared.loginResponse
                    ?? UserDefaultsHelper.retrieveLoginDetailsFromUserDefaults().0

                if let loginDetails = loginDetailsForPersistence {
                    UserDefaultsHelper.persistLoginDetailsIfRemembered(
                        loginDetails: loginDetails,
                        tokenResponse: loginResponse
                    )
                }

                return true
            } catch {
                print("Failed to decode LoginResponse:", error)
                return false
            }
        } else {
            print("Unsupported response type:", type(of: response))
            return false
        }
        
       
    }
    
    
    
}
