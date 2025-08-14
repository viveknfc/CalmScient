//
//  DrinkingTakingControlResponse.swift
//  CalmscientIOS
//
//  Created by NFC Solutions on 3/10/25.
//

import Foundation

struct DrinkingTakingControlResponse: Codable {
    let statusResponse: StatusResponse?
    let index: [Index]?
    let courseLists: [CourseList]?
    let intoDates: [IntoDate]?
}

struct StatusResponse: Codable {
    let responseMessage: String?
    let responseCode: Int?
}

struct Index: Codable {
    let goalType: String?
    let goalDescription: String?
    let goalSetupID: Int?
    let goal: Int?
    let now: Int?
}

struct CourseList: Codable {
    let id: Int?
    let patientID: Int?
    let clientID: Int?
    let plID: Int?
    let courseName: String?
    let courseID: Int?
    let isEnable: Int?
    let isCompleted: Int?
    let skipTutorialFlag: Int?
}

struct IntoDate: Codable {
    let eventDate: String?
    let colorCode: String?
    let eventDescription: String?
}

