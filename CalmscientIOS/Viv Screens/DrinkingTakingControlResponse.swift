//
//  DrinkingTakingControlResponse.swift
//  CalmscientIOS
//
//  Created by NFC Solutions on 3/10/25.
//

import Foundation

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let drinkingTakingControlResponse = try? JSONDecoder().decode(DrinkingTakingControlResponse.self, from: jsonData)


// MARK: - DrinkingTakingControlResponse
struct DrinkingTakingControlResponse: Codable {
    let statusResponse: StatusResponse?
    let index: [Index]?
    let courseLists: [CourseList]?
    let intoDates: [IntoDate]?
}

// MARK: - CourseList
struct CourseList: Codable {
    let id, patientID, clientID, plID: Int?
    let courseName: String?
    let courseID, isEnable, isCompleted, skipTutorialFlag: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case patientID = "patientId"
        case clientID = "clientId"
        case plID = "plId"
        case courseName
        case courseID = "courseId"
        case isEnable, isCompleted, skipTutorialFlag
    }
}

// MARK: - Index
struct Index: Codable {
    let goalType: String?
    let goalDescription: String?
    let goalSetupID, goal, now: Int?

    enum CodingKeys: String, CodingKey {
        case goalType, goalDescription
        case goalSetupID = "goalSetupId"
        case goal, now
    }
}

// MARK: - IntoDate
struct IntoDate: Codable {
    let eventDate, colorCode, eventDescription: String?
}

// MARK: - StatusResponse
struct StatusResponse: Codable {
    let responseMessage: String?
    let responseCode: Int?
}
