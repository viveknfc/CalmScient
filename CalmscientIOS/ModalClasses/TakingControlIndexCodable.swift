//
//  TakingControlIndexCodable.swift
//  CalmscientIOS
//
//  Created by Arimilli Venkata Rama Kishore on 18/06/24.
//

import Foundation

class Goal: Codable {
    let goalType: String
    let goalDescription: String
    let goalDeadline: String
    let goalSetupId: Int
    let goal: Int
    let now: Int? // Can be nil, so it's optional
    
    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(goalType, forKey: .goalType)
        try container.encode(goalDescription, forKey: .goalDescription)
        try container.encode(goalDeadline, forKey: .goalDeadline)
        try container.encode(goalSetupId, forKey: .goalSetupId)
        try container.encode(goal, forKey: .goal)
        try container.encodeIfPresent(now, forKey: .now)
    }
    
    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        goalType = try container.decode(String.self, forKey: .goalType)
        goalDescription = try container.decode(String.self, forKey: .goalDescription)
        goalDeadline = try container.decode(String.self, forKey: .goalDeadline)
        goalSetupId = try container.decode(Int.self, forKey: .goalSetupId)
        goal = try container.decode(Int.self, forKey: .goal)
        now = try container.decodeIfPresent(Int.self, forKey: .now)
    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case goalType
        case goalDescription
        case goalDeadline
        case goalSetupId
        case goal
        case now
    }
}

// Define the Course class
class Course: Codable {
    let id: Int
    let patientId: Int
    let clientId: Int
    let plId: Int
    let courseName: String
    let courseId: Int
    let isEnable: Int
    let isCompleted: Int
    let skipTutorialFlag: Int
    
    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(patientId, forKey: .patientId)
        try container.encode(clientId, forKey: .clientId)
        try container.encode(plId, forKey: .plId)
        try container.encode(courseName, forKey: .courseName)
        try container.encode(courseId, forKey: .courseId)
        try container.encode(isEnable, forKey: .isEnable)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(skipTutorialFlag, forKey: .skipTutorialFlag)
    }
    
    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        patientId = try container.decode(Int.self, forKey: .patientId)
        clientId = try container.decode(Int.self, forKey: .clientId)
        plId = try container.decode(Int.self, forKey: .plId)
        courseName = try container.decode(String.self, forKey: .courseName)
        courseId = try container.decode(Int.self, forKey: .courseId)
        isEnable = try container.decode(Int.self, forKey: .isEnable)
        isCompleted = try container.decode(Int.self, forKey: .isCompleted)
        skipTutorialFlag = try container.decode(Int.self, forKey: .skipTutorialFlag)
    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case id
        case patientId
        case clientId
        case plId
        case courseName
        case courseId
        case isEnable
        case isCompleted
        case skipTutorialFlag
    }
}

// Define a parent structure to hold both Goals and Courses lists
struct TakingControlIndexResponse: Codable {
    let statusResponse: ResponseDetails
    let index: [Goal]
    let courseLists: [Course]
    
    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(statusResponse, forKey: .statusResponse)
        try container.encode(index, forKey: .index)
        try container.encode(courseLists, forKey: .courseLists)
    }
    
    // Decoding function
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        statusResponse = try container.decode(ResponseDetails.self, forKey: .statusResponse)
        index = try container.decode([Goal].self, forKey: .index)
        courseLists = try container.decode([Course].self, forKey: .courseLists)
    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case statusResponse
        case index
        case courseLists
    }
}


class TakingControlIndexRequestForm: EndPointRequest {
    
    var baseURL: String = baseURLString
    var path: String = "patients/api/v1/takingControl/getTakingControlIndex"
    var httpMethod: HTTPMethod = .post
    var requestBody: [String : Any]
    
    required init(_ requestBodyParams:[String:Any]) {
        self.requestBody = requestBodyParams
    }
}
