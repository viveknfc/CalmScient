//
//  CoursesAPICodables.swift
//  CalmscientIOS
//
//  Created by Arimilli Venkata Rama Kishore on 04/06/24.
//

import Foundation

class CoursesSessionInfo: Codable {
    var sessionId: String
    var userName: String
    var expiry: String

    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sessionId, forKey: .sessionId)
        try container.encode(userName, forKey: .userName)
        try container.encode(expiry, forKey: .expiry)
    }

    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sessionId = try container.decode(String.self, forKey: .sessionId)
        userName = try container.decode(String.self, forKey: .userName)
        expiry = try container.decode(String.self, forKey: .expiry)
    }

    // Coding keys
    enum CodingKeys: String, CodingKey {
        case sessionId
        case userName
        case expiry
    }
}

class GetCourseSessionIdRequestForm: EndPointRequest {
    
    var baseURL: String = baseURLString
    var path: String = "identity/api/v1/user/getSession"
    var httpMethod: HTTPMethod = .get
    var requestBody: [String : Any] = [:]
    
    required init() {
        
    }
}
