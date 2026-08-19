//
//  WearableAverageAPICodables.swift
//  Calmscient
//
//  Created by NFC Solutions on 19/08/26.
//

import Foundation

// MARK: - Top-level response
//
// `GET patients/api/v1/health/wearable-data/average?patientId=&date=&period=`
//
// The server buckets the whole surrounding period and returns *every* bucket, including
// the ones it has no records for — those come back with `recordCount: 0` and null
// category objects. That's deliberate and useful: the chart can draw a full JAN…DEC axis
// without inventing the empty months itself.

class WearableAverageResponse: Codable {
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
    /// Echoed back uppercased ("MONTH"), not in the lowercase form the request sends.
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

// MARK: - One bucket (a day, a month or a year)

class WearableAverageBucket: Codable {
    /// Ready-made axis label: "MON" / "JAN" / "2026". Used as-is so the chart's x-axis
    /// always agrees with whatever the server considers a bucket.
    let label: String?
    let startDate: String?
    let endDate: String?
    /// Raw rows behind the average. Zero means the bucket is a gap, not a zero reading.
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
}

// MARK: - Trend timeframe (the Weekly / Monthly / Yearly control)

/// The three tabs above the chart, and the `period` value each one sends.
///
/// Separate from `HealthTimeframe` (which drives the on-device HealthKit charts and has a
/// `.daily` case): this one exists to describe what the *averages endpoint* supports, and
/// conflating them would mean a `.daily` tab the server can't answer.
enum HealthTrendPeriod: String, CaseIterable, Identifiable {
    case weekly
    case monthly
    case yearly

    var id: String { rawValue }

    /// Sent as `period`. Lowercase going out; the response echoes it uppercased.
    var apiValue: String {
        switch self {
        case .weekly:  return "week"
        case .monthly: return "month"
        case .yearly:  return "year"
        }
    }

    var localizedTitle: String {
        switch self {
        case .weekly:  return "Weekly".localized
        case .monthly: return "Monthly".localized
        case .yearly:  return "Yearly".localized
        }
    }
}
