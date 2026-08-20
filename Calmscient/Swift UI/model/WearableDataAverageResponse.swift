//
//  WearableDataAverageResponse.swift
//  Calmscient
//
//  `GET patients/api/v1/health/wearable-data/average?patientId=&date=&period=`
//  Returns one bucket per slot in the period (7 days / 12 months / N years) with
//  the averaged value of every wearable field in that bucket.
//
//  Created by NFC Solutions on 19/08/26.
//

import Foundation

// MARK: - Period

/// `period` query value accepted by the averages endpoint.
enum HealthMetricAveragePeriod: String, CaseIterable, Identifiable {
    case week  = "WEEK"
    case month = "MONTH"
    case year  = "YEAR"

    var id: String { rawValue }

    /// Localizable tab title.
    var titleKey: String {
        switch self {
        case .week:  return "Weekly"
        case .month: return "Monthly"
        case .year:  return "Yearly"
        }
    }
}

// MARK: - Top-level response

class WearableDataAverageResponse: Codable {
    let statusResponse: ResponseDetails
    let data: WearableAverageData?

    enum CodingKeys: String, CodingKey {
        case statusResponse
        case data
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        statusResponse = try c.decode(ResponseDetails.self, forKey: .statusResponse)
        data = try c.decodeIfPresent(WearableAverageData.self, forKey: .data)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(statusResponse, forKey: .statusResponse)
        try c.encodeIfPresent(data, forKey: .data)
    }
}

// MARK: - Data

class WearableAverageData: Codable {
    let patientId: Int?
    let period: String?
    let startDate: String?
    let endDate: String?
    let buckets: [WearableAverageBucket]?

    enum CodingKeys: String, CodingKey {
        case patientId
        case period
        case startDate
        case endDate
        case buckets
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        patientId = try c.decodeIfPresent(Int.self, forKey: .patientId)
        period = try c.decodeIfPresent(String.self, forKey: .period)
        startDate = try c.decodeIfPresent(String.self, forKey: .startDate)
        endDate = try c.decodeIfPresent(String.self, forKey: .endDate)
        buckets = try c.decodeIfPresent([WearableAverageBucket].self, forKey: .buckets)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(patientId, forKey: .patientId)
        try c.encodeIfPresent(period, forKey: .period)
        try c.encodeIfPresent(startDate, forKey: .startDate)
        try c.encodeIfPresent(endDate, forKey: .endDate)
        try c.encodeIfPresent(buckets, forKey: .buckets)
    }
}

// MARK: - Bucket
//
// The category payloads use exactly the same field names as the single-day
// `wearable-data` response, so the existing codables are reused as-is.

class WearableAverageBucket: Codable {
    let label: String?
    let startDate: String?
    let endDate: String?
    let recordCount: Int?
    let daysWithData: Int?
    let vitals: WearableVitals?
    let activity: WearableActivity?
    let body: WearableBody?
    let sleep: WearableSleep?
    let nutrition: WearableNutrition?
    let wellness: WearableWellness?

    enum CodingKeys: String, CodingKey {
        case label
        case startDate
        case endDate
        case recordCount
        case daysWithData
        case vitals
        case activity
        case body
        case sleep
        case nutrition
        case wellness
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        label = try c.decodeIfPresent(String.self, forKey: .label)
        startDate = try c.decodeIfPresent(String.self, forKey: .startDate)
        endDate = try c.decodeIfPresent(String.self, forKey: .endDate)
        recordCount = try c.decodeIfPresent(Int.self, forKey: .recordCount)
        daysWithData = try c.decodeIfPresent(Int.self, forKey: .daysWithData)
        vitals = try c.decodeIfPresent(WearableVitals.self, forKey: .vitals)
        activity = try c.decodeIfPresent(WearableActivity.self, forKey: .activity)
        body = try c.decodeIfPresent(WearableBody.self, forKey: .body)
        sleep = try c.decodeIfPresent(WearableSleep.self, forKey: .sleep)
        nutrition = try c.decodeIfPresent(WearableNutrition.self, forKey: .nutrition)
        wellness = try c.decodeIfPresent(WearableWellness.self, forKey: .wellness)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(label, forKey: .label)
        try c.encodeIfPresent(startDate, forKey: .startDate)
        try c.encodeIfPresent(endDate, forKey: .endDate)
        try c.encodeIfPresent(recordCount, forKey: .recordCount)
        try c.encodeIfPresent(daysWithData, forKey: .daysWithData)
        try c.encodeIfPresent(vitals, forKey: .vitals)
        try c.encodeIfPresent(activity, forKey: .activity)
        try c.encodeIfPresent(body, forKey: .body)
        try c.encodeIfPresent(sleep, forKey: .sleep)
        try c.encodeIfPresent(nutrition, forKey: .nutrition)
        try c.encodeIfPresent(wellness, forKey: .wellness)
    }

    /// True when the backend reported no wearable rows in this slot. Both counters
    /// have to be empty/absent — a payload that omits `recordCount` but reports
    /// `daysWithData` still carries plottable averages.
    var isEmptyBucket: Bool { (recordCount ?? 0) <= 0 && (daysWithData ?? 0) <= 0 }
}
