//
//  getTakingControlIntroDataModal.swift
//  CalmscientIOS
//
//  Created by NFC User on 09/04/25.
//

import Foundation

struct IntroductionResponse: Codable {
    let statusResponse: StatusResponse
    let takingControlIntroduction: TakingControlIntroduction
}

struct TakingControlIntroduction: Codable {
    let introDates: [String]
    let result: IntroductionResult
}

struct IntroductionResult: Codable {
    let auditFlag: Int
    let cageFlag: Int
    let dastFlag: Int
    // Include other fields if needed
}

