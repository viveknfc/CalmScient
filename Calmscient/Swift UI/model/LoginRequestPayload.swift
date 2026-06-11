//
//  LoginRequestPayload.swift
//  Calmscient
//
//  Encodable body for POST identity/api/v1/settings/userLogin
//
//  Vivek
//  14 May 2026
//
import Foundation

struct LoginRequestPayload: Encodable {
    let userName: String
    let password: String
    let rememberMe: Int
    let deviceToken: String
    let mobilePlatform: String
    let timeZone: String

    /// Body dictionary for `APIService.userLogin` / `getRequestWithToken` (matches `LoginVC` keys).
    var asRequestParameters: [String: Any] {
        [
            "userName": userName,
            "password": password,
            "rememberMe": rememberMe,
            "deviceToken": deviceToken,
            "mobilePlatform": mobilePlatform,
            "timeZone": timeZone
        ]
    }
}
