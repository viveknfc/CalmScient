//
//  WearableDataRangeResponse.swift
//  Calmscient
//
//  Created by NFC Solutions on 12/08/26.
//

// MARK: - Range response

class WearableDataRangeResponse: Codable {
    let statusResponse: ResponseDetails
    let data: [WearableData]?

    enum CodingKeys: String, CodingKey {
        case statusResponse
        case data
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        statusResponse = try c.decode(ResponseDetails.self, forKey: .statusResponse)
        data = try c.decodeIfPresent([WearableData].self, forKey: .data)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(statusResponse, forKey: .statusResponse)
        try c.encodeIfPresent(data, forKey: .data)
    }
}
