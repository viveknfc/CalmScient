//
//  UserLoginInfo.swift
//  CalmscientIOS
//
//  Created by NFC on 03/05/24.
//

import Foundation

public class FailureResponse: Codable {
    let statusResponse: ResponseDetails
    
    enum CodingKeys: CodingKey {
        case statusResponse
    }
    
    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.statusResponse = try container.decode(ResponseDetails.self, forKey: .statusResponse)
    }
    
   
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.statusResponse, forKey: .statusResponse)
    }
}


class TokenResponse: Codable {
    var accessToken: String
    var expiresIn: Int
    var refreshExpiresIn: Int
    var refreshToken: String
    var tokenType: String
    var idToken: String?
    var notBeforePolicy: Int
    var sessionState: String
    var scope: String
    var error: String?
    var errorDescription: String?
    var errorUri: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case refreshExpiresIn = "refresh_expires_in"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case idToken = "id_token"
        case notBeforePolicy = "not-before-policy"
        case sessionState = "session_state"
        case scope
        case error
        case errorDescription = "error_description"
        case errorUri = "error_uri"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decode(String.self, forKey: .accessToken)
        expiresIn = try container.decode(Int.self, forKey: .expiresIn)
        refreshExpiresIn = try container.decode(Int.self, forKey: .refreshExpiresIn)
        refreshToken = try container.decode(String.self, forKey: .refreshToken)
        tokenType = try container.decode(String.self, forKey: .tokenType)
        idToken = try container.decodeIfPresent(String.self, forKey: .idToken)
        notBeforePolicy = try container.decode(Int.self, forKey: .notBeforePolicy)
        sessionState = try container.decode(String.self, forKey: .sessionState)
        scope = try container.decode(String.self, forKey: .scope)
        error = try container.decodeIfPresent(String.self, forKey: .error)
        errorDescription = try container.decodeIfPresent(String.self, forKey: .errorDescription)
        errorUri = try container.decodeIfPresent(String.self, forKey: .errorUri)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accessToken, forKey: .accessToken)
        try container.encode(expiresIn, forKey: .expiresIn)
        try container.encode(refreshExpiresIn, forKey: .refreshExpiresIn)
        try container.encode(refreshToken, forKey: .refreshToken)
        try container.encode(tokenType, forKey: .tokenType)
        try container.encodeIfPresent(idToken, forKey: .idToken)
        try container.encode(notBeforePolicy, forKey: .notBeforePolicy)
        try container.encode(sessionState, forKey: .sessionState)
        try container.encode(scope, forKey: .scope)
        try container.encodeIfPresent(error, forKey: .error)
        try container.encodeIfPresent(errorDescription, forKey: .errorDescription)
        try container.encodeIfPresent(errorUri, forKey: .errorUri)
    }
}

class ResponseDetails: Codable {
    let responseMessage: String
    let responseCode: Int
    
    enum CodingKeys: CodingKey {
        case responseMessage
        case responseCode
    }
    
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.responseMessage, forKey: .responseMessage)
        try container.encode(self.responseCode, forKey: .responseCode)
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.responseMessage = try container.decode(String.self, forKey: .responseMessage)
        self.responseCode = try container.decode(Int.self, forKey: .responseCode)
    }
}


class LoginDetails: Codable {
    let patientID: Int
    let patientLocationID: Int
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let clientID: Int
    let userID: Int
    let userTypeID: Int
    let securityGroupID: Int
    let userCode: String
    let lastActivity: String?
    let lastLogin: String?
    let loginCount: Int
    let userType: String
    let locationName: String
    let address: String
    let city: Int
    let providerID: Int?
    let providerName: String?
    let providerCode: String?
    
    enum CodingKeys: CodingKey {
        case patientID
        case patientLocationID
        case firstName
        case lastName
        case email
        case phone
        case clientID
        case userID
        case userTypeID
        case securityGroupID
        case userCode
        case lastActivity
        case lastLogin
        case loginCount
        case userType
        case locationName
        case address
        case city
        case providerID
        case providerName
        case providerCode
    }
    
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.patientID, forKey: .patientID)
        try container.encode(self.patientLocationID, forKey: .patientLocationID)
        try container.encode(self.firstName, forKey: .firstName)
        try container.encode(self.lastName, forKey: .lastName)
        try container.encode(self.email, forKey: .email)
        try container.encode(self.phone, forKey: .phone)
        try container.encode(self.clientID, forKey: .clientID)
        try container.encode(self.userID, forKey: .userID)
        try container.encode(self.userTypeID, forKey: .userTypeID)
        try container.encode(self.securityGroupID, forKey: .securityGroupID)
        try container.encode(self.userCode, forKey: .userCode)
        try container.encode(self.lastActivity, forKey: .lastActivity)
        try container.encode(self.lastLogin, forKey: .lastLogin)
        try container.encode(self.loginCount, forKey: .loginCount)
        try container.encode(self.userType, forKey: .userType)
        try container.encode(self.locationName, forKey: .locationName)
        try container.encode(self.address, forKey: .address)
        try container.encode(self.city, forKey: .city)
        try container.encode(self.providerID, forKey: .providerID)
        try container.encode(self.providerName, forKey: .providerName)
        try container.encode(self.providerCode, forKey: .providerCode)
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.patientID = try container.decode(Int.self, forKey: .patientID)
        self.patientLocationID = try container.decode(Int.self, forKey: .patientLocationID)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.email = try container.decode(String.self, forKey: .email)
        self.phone = try container.decode(String.self, forKey: .phone)
        self.clientID = try container.decode(Int.self, forKey: .clientID)
        self.userID = try container.decode(Int.self, forKey: .userID)
        self.userTypeID = try container.decode(Int.self, forKey: .userTypeID)
        self.securityGroupID = try container.decode(Int.self, forKey: .securityGroupID)
        self.userCode = try container.decode(String.self, forKey: .userCode)
        self.lastActivity = try container.decodeIfPresent(String.self, forKey: .lastActivity)
        self.lastLogin = try container.decodeIfPresent(String.self, forKey: .lastLogin)
        self.loginCount = try container.decode(Int.self, forKey: .loginCount)
        self.userType = try container.decode(String.self, forKey: .userType)
        self.locationName = try container.decode(String.self, forKey: .locationName)
        self.address = try container.decode(String.self, forKey: .address)
        self.city = try container.decode(Int.self, forKey: .city)
        self.providerID = try container.decodeIfPresent(Int.self, forKey: .providerID)
        self.providerName = try container.decodeIfPresent(String.self, forKey: .providerName)
        self.providerCode = try container.decodeIfPresent(String.self, forKey: .providerCode)
    }
}


class LoginResponse: Codable {
    let statusResponse: ResponseDetails
    let loginDetails: LoginDetails
    let tokenResponse:TokenResponse
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.statusResponse = try container.decode(ResponseDetails.self, forKey: .statusResponse)
        self.loginDetails = try container.decode(LoginDetails.self, forKey: .loginDetails)
        self.tokenResponse = try container.decode(TokenResponse.self, forKey: .tokenResponse)
    }
    
    enum CodingKeys: String, CodingKey {
        case statusResponse
        case loginDetails
        case tokenResponse = "token"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.statusResponse, forKey: .statusResponse)
        try container.encode(self.loginDetails, forKey: .loginDetails)
        try container.encode(self.tokenResponse, forKey: .tokenResponse)
    }
}
