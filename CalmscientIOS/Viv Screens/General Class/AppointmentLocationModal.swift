//
//  AppointmentLocationModal.swift
//  CalmscientIOS
//
//  Created by NFC User on 21/03/25.
//

import Foundation

struct LocationResponse: Codable {
    let statusResponse: StatusResponse
    let totalRecords: Int
    let locationDetails: [LocationDetail]
}

struct LocationDetail: Codable {
    let locationId: Int
    let locationName: String
}

struct ProviderResponse: Codable {
    let statusResponse: StatusResponse
    let providerList: [ProviderDetail]
}

struct ProviderDetail: Codable {
    let providerId: Int
    let firstName: String
}
