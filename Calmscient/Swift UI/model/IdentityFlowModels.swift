//
//  IdentityFlowModels.swift
//  Calmscient
//
//  Response types for license validation and OTP (identity APIs). Forgot-password uses `APIService.generateOTP` / `validateOTP`.
//
//  Vivek
//  14 May 2026
//
import Foundation

/// Response wrapper for `identity/api/v1/license/validateLicenseKey` (matches `UserRegistrationViewController` parsing).
struct ValidateLicenseKeyResponse: Codable {
    let statusResponse: ValidateLicenseStatusResponse
}

struct ValidateLicenseStatusResponse: Codable {
    let responseCode: Int
    let responseMessage: String
}

enum LicenseValidationResponseParser {
    /// Parses `validateLicenseKey` callback payload (same shape as legacy `UserRegistrationViewController`).
    static func status(from response: AnyObject) -> (code: Int, message: String)? {
        guard let responseDict = response as? [String: Any],
              let statusResponse = responseDict["statusResponse"] as? [String: Any],
              let code = statusResponse["responseCode"] as? Int,
              let message = statusResponse["responseMessage"] as? String else {
            return nil
        }
        return (code, message)
    }
}

/// Flat JSON from `identity/api/v1/settings/validateOTP` (matches `CheckMailVC` parsing).
enum ValidateOTPResponseParser {
    static func result(from response: AnyObject) -> (code: Int, message: String)? {
        guard let json = response as? [String: Any],
              let code = json["responseCode"] as? Int,
              let message = json["responseMessage"] as? String else {
            return nil
        }
        return (code, message)
    }
}
