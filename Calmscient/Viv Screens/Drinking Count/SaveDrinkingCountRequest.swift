//
//  SaveDrinkingCountRequest.swift
//  CalmscientIOS
//
//  Created by NFC Solutions on 3/12/25.
//

import Foundation


// MARK: - SaveDrinkingCountRequest
struct SaveDrinkingCountRequest: Codable {
    let alcohol: [Alcohol]?
}

// MARK: - Alcohol
struct Alcohol: Codable {
    let activityDate: String?
    let clientID, drinkID: Int?
    let flag: String?
    let patientID, plID: Int?
    var quantity: Int?

    enum CodingKeys: String, CodingKey {
        case activityDate
        case clientID = "clientId"
        case drinkID = "drinkId"
        case flag
        case patientID = "patientId"
        case plID = "plId"
        case quantity
    }
}

