//
//  WearableDataAPICodables.swift
//  Calmscient
//
//  Created by NFC Solutions on 12/08/26.
//

import Foundation

// MARK: - Top-level response
class WearableDataResponse: Codable {
    let statusResponse: ResponseDetails
    let data: WearableData?

    enum CodingKeys: String, CodingKey {
        case statusResponse
        case data
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        statusResponse = try c.decode(ResponseDetails.self, forKey: .statusResponse)
        data = try c.decodeIfPresent(WearableData.self, forKey: .data)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(statusResponse, forKey: .statusResponse)
        try c.encodeIfPresent(data, forKey: .data)
    }
}

// MARK: - Data
class WearableData: Codable {
    let patientId: Int?
    let date: String?
    let timestamp: String?
    let sourceDevice: String?
    let vitals: WearableVitals?
    let activity: WearableActivity?
    let body: WearableBody?
    let sleep: WearableSleep?
    let nutrition: WearableNutrition?
    let wellness: WearableWellness?

    enum CodingKeys: String, CodingKey {
        case patientId
        case date
        case timestamp
        case sourceDevice
        case vitals
        case activity
        case body
        case sleep
        case nutrition
        case wellness
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        patientId = try c.decodeIfPresent(Int.self, forKey: .patientId)
        date = try c.decodeIfPresent(String.self, forKey: .date)
        timestamp = try c.decodeIfPresent(String.self, forKey: .timestamp)
        sourceDevice = try c.decodeIfPresent(String.self, forKey: .sourceDevice)
        vitals = try c.decodeIfPresent(WearableVitals.self, forKey: .vitals)
        activity = try c.decodeIfPresent(WearableActivity.self, forKey: .activity)
        body = try c.decodeIfPresent(WearableBody.self, forKey: .body)
        sleep = try c.decodeIfPresent(WearableSleep.self, forKey: .sleep)
        nutrition = try c.decodeIfPresent(WearableNutrition.self, forKey: .nutrition)
        wellness = try c.decodeIfPresent(WearableWellness.self, forKey: .wellness)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(patientId, forKey: .patientId)
        try c.encodeIfPresent(date, forKey: .date)
        try c.encodeIfPresent(timestamp, forKey: .timestamp)
        try c.encodeIfPresent(sourceDevice, forKey: .sourceDevice)
        try c.encodeIfPresent(vitals, forKey: .vitals)
        try c.encodeIfPresent(activity, forKey: .activity)
        try c.encodeIfPresent(body, forKey: .body)
        try c.encodeIfPresent(sleep, forKey: .sleep)
        try c.encodeIfPresent(nutrition, forKey: .nutrition)
        try c.encodeIfPresent(wellness, forKey: .wellness)
    }
}

// MARK: - Vitals
class WearableVitals: Codable {
    let heartRate: String?
    let stressLevel: String?
    let restingHeartRate: String?
    let spo2: String?
    let respiratoryRate: String?
    let systolicPressure: String?
    let diastolicPressure: String?
    let hrv: String?

    enum CodingKeys: String, CodingKey {
        case heartRate
        case stressLevel
        case restingHeartRate
        case spo2
        case respiratoryRate
        case systolicPressure
        case diastolicPressure
        case hrv
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        heartRate = try c.decodeIfPresent(String.self, forKey: .heartRate)
        stressLevel = try c.decodeIfPresent(String.self, forKey: .stressLevel)
        restingHeartRate = try c.decodeIfPresent(String.self, forKey: .restingHeartRate)
        spo2 = try c.decodeIfPresent(String.self, forKey: .spo2)
        respiratoryRate = try c.decodeIfPresent(String.self, forKey: .respiratoryRate)
        systolicPressure = try c.decodeIfPresent(String.self, forKey: .systolicPressure)
        diastolicPressure = try c.decodeIfPresent(String.self, forKey: .diastolicPressure)
        hrv = try c.decodeIfPresent(String.self, forKey: .hrv)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(heartRate, forKey: .heartRate)
        try c.encodeIfPresent(stressLevel, forKey: .stressLevel)
        try c.encodeIfPresent(restingHeartRate, forKey: .restingHeartRate)
        try c.encodeIfPresent(spo2, forKey: .spo2)
        try c.encodeIfPresent(respiratoryRate, forKey: .respiratoryRate)
        try c.encodeIfPresent(systolicPressure, forKey: .systolicPressure)
        try c.encodeIfPresent(diastolicPressure, forKey: .diastolicPressure)
        try c.encodeIfPresent(hrv, forKey: .hrv)
    }
}

// MARK: - Activity
class WearableActivity: Codable {
    let steps: String?
    let distance: String?
    let activeCalories: String?
    let totalCalories: String?
    let exerciseMinutes: String?
    let exerciseType: String?

    enum CodingKeys: String, CodingKey {
        case steps
        case distance
        case activeCalories
        case totalCalories
        case exerciseMinutes
        case exerciseType
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        steps = try c.decodeIfPresent(String.self, forKey: .steps)
        distance = try c.decodeIfPresent(String.self, forKey: .distance)
        activeCalories = try c.decodeIfPresent(String.self, forKey: .activeCalories)
        totalCalories = try c.decodeIfPresent(String.self, forKey: .totalCalories)
        exerciseMinutes = try c.decodeIfPresent(String.self, forKey: .exerciseMinutes)
        exerciseType = try c.decodeIfPresent(String.self, forKey: .exerciseType)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(steps, forKey: .steps)
        try c.encodeIfPresent(distance, forKey: .distance)
        try c.encodeIfPresent(activeCalories, forKey: .activeCalories)
        try c.encodeIfPresent(totalCalories, forKey: .totalCalories)
        try c.encodeIfPresent(exerciseMinutes, forKey: .exerciseMinutes)
        try c.encodeIfPresent(exerciseType, forKey: .exerciseType)
    }
}

// MARK: - Body
class WearableBody: Codable {
    let weight: String?
    let height: String?
    let bodyFat: String?
    let bloodGlucose: String?
    let bmr: String?

    enum CodingKeys: String, CodingKey {
        case weight
        case height
        case bodyFat
        case bloodGlucose
        case bmr
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        weight = try c.decodeIfPresent(String.self, forKey: .weight)
        height = try c.decodeIfPresent(String.self, forKey: .height)
        bodyFat = try c.decodeIfPresent(String.self, forKey: .bodyFat)
        bloodGlucose = try c.decodeIfPresent(String.self, forKey: .bloodGlucose)
        bmr = try c.decodeIfPresent(String.self, forKey: .bmr)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(weight, forKey: .weight)
        try c.encodeIfPresent(height, forKey: .height)
        try c.encodeIfPresent(bodyFat, forKey: .bodyFat)
        try c.encodeIfPresent(bloodGlucose, forKey: .bloodGlucose)
        try c.encodeIfPresent(bmr, forKey: .bmr)
    }
}

// MARK: - Sleep
class WearableSleep: Codable {
    let sleepHours: String?

    enum CodingKeys: String, CodingKey {
        case sleepHours
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        sleepHours = try c.decodeIfPresent(String.self, forKey: .sleepHours)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(sleepHours, forKey: .sleepHours)
    }
}

// MARK: - Nutrition
class WearableNutrition: Codable {
    let hydration: String?

    enum CodingKeys: String, CodingKey {
        case hydration
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        hydration = try c.decodeIfPresent(String.self, forKey: .hydration)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(hydration, forKey: .hydration)
    }
}

// MARK: - Wellness
class WearableWellness: Codable {
    let wellnessMinutes: String?

    enum CodingKeys: String, CodingKey {
        case wellnessMinutes
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        wellnessMinutes = try c.decodeIfPresent(String.self, forKey: .wellnessMinutes)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(wellnessMinutes, forKey: .wellnessMinutes)
    }
}
