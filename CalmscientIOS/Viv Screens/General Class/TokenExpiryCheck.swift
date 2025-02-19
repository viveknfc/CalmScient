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
    
    //Refresh API
    func refreshAccessToken(from viewController: UIViewController?, completion: @escaping (Bool) -> Void) {
        guard let refreshToken = ApplicationSharedInfo.shared.tokenResponse?.refreshToken else {
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
                
                UserDefaultsHelper.saveLoginDetailsToUserDefaults(loginDetails: ApplicationSharedInfo.shared.loginResponse!, tokenResponse: loginResponse)
                
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
