//
//  UserStartUpScreen.swift
//  CalmscientIOS
//
//  Created by KA on NA.
//

import Foundation

class UserMoodData: Codable {
    var moodQuestion: String
    let options: [UserMoodOption]
}

class UserMoodOption: Codable {
    let optionType: String
    let optionTypeID: Int
    let image: String
}

class UserSleepData: Codable {
    let sleepQuestion: String
    let option1: String
    let option2: String
    let option3: String
    let option4: String
    let option5: String
    let option6: String
    let option7: String
    let option8: String
    let option9: String
}

class UserTimeSpendData: Codable {
    let timeSpendQuestion: String
    let option1: String
    let option2: String
    let option3: String
    let option4: String
    let option5: String
}

class UserMedicineData: Codable {
    var medicineQuestion: String
    let option1: String
    let option2: String
}

class UserJournalData: Codable {
    var journalKey: String
    let optionType: String
}

struct StartupAnswer: Codable {
    let activitySection: String
    let activityResponse: String
}

class UserStartupScreenDayData: Codable {
    var wish: String = ""
    var moodData: UserMoodData?
    var sleepData: UserSleepData?
    var timeSpendData: UserTimeSpendData?
    var medicineData: UserMedicineData?
    var journalData: UserJournalData?
    var dayTimeValue:DayTimeValue?
    
    var moodAnswer:Int?
    var sleepAnswer:Int?
    var medicineAnswer:String?
    var timeSpendAnswer:String?
    var journalAnswer:String?
    
    var startupAnswersDtoList: [StartupAnswer]?
    
    static func getStartUpScreenData(fromDate:Date = Date()) -> UserStartupScreenDayData? {
       
        guard let jsonData = loadJson(filename:  "UserStartUpScreenDayData") else {
            return nil
        }
        guard let dayWiseData = try? JSONDecoder().decode(UserStartupScreenDayData.self, from: jsonData) else {
            return nil
        }
        
        print("the getStartUpScreenData is", dayWiseData)

        dayWiseData.dayTimeValue = getDayTime(date: fromDate)
//        dayWiseData.dayTimeValue = .Evening
        switch dayWiseData.dayTimeValue {
        case .Morning:
            dayWiseData.moodData?.moodQuestion = AppHelper.getLocalizeString(str: "How's_your_mood_so_far")
            dayWiseData.medicineData?.medicineQuestion = AppHelper.getLocalizeString(str: "Did_you_take_your_meds_this_morning")
            dayWiseData.timeSpendData = nil

            dayWiseData.journalData?.journalKey = "Daily journal"
        case .Afternoon:
            dayWiseData.moodData?.moodQuestion = AppHelper.getLocalizeString(str: "How_is_your_mood_right_now")
            dayWiseData.medicineData = nil
            dayWiseData.sleepData = nil
            dayWiseData.timeSpendData = nil
            dayWiseData.journalData = nil
        case .Evening:
            dayWiseData.moodData?.moodQuestion = AppHelper.getLocalizeString(str: "How_was_your_day")
            dayWiseData.medicineData?.medicineQuestion = AppHelper.getLocalizeString(str: "Did_you_take_your_meds")
            dayWiseData.sleepData = nil
            dayWiseData.journalData?.journalKey = "Daily journal"
        case .none:
            break
        }
        return dayWiseData
    }
    
    
    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        wish = try container.decode(String.self, forKey: .wish)
        moodData = try container.decodeIfPresent(UserMoodData.self, forKey: .moodData)
        sleepData = try container.decodeIfPresent(UserSleepData.self, forKey: .sleepData)
        timeSpendData = try container.decodeIfPresent(UserTimeSpendData.self, forKey: .timeSpendData)
        medicineData = try container.decodeIfPresent(UserMedicineData.self, forKey: .medicineData)
        journalData = try container.decodeIfPresent(UserJournalData.self, forKey: .journalData)
        startupAnswersDtoList = try container.decodeIfPresent([StartupAnswer].self, forKey: .startupAnswersDtoList)
    }
    
    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(wish, forKey: .wish)
        try container.encodeIfPresent(moodData, forKey: .moodData)
        try container.encodeIfPresent(sleepData, forKey: .sleepData)
        try container.encodeIfPresent(timeSpendData, forKey: .timeSpendData)
        try container.encodeIfPresent(medicineData, forKey: .medicineData)
        try container.encodeIfPresent(journalData, forKey: .journalData)
        try container.encodeIfPresent(startupAnswersDtoList, forKey: .startupAnswersDtoList)

    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case wish
        case moodData
        case sleepData
        case timeSpendData
        case medicineData
        case journalData
        case startupAnswersDtoList
    }
    
    private static func getDayTime(date: Date = Date()) -> DayTimeValue {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)

        // Calculate the total minutes since the start of the day
        let totalMinutes = hour * 60 + minute

        switch totalMinutes {
        case (3 * 60)..<(18 * 60): // 3:00 AM to 5:59 PM
            return DayTimeValue.Morning
        default: // 6:00 PM to 2:59 AM
            return DayTimeValue.Evening
        }
    }
    
    private static func loadJson(filename fileName: String) -> Data? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                return data
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
        return nil
    }
}


public enum UserStartUpScreenDayTimeItems {
    case moodData
    case sleepData
    case timeSpendData
    case medicineData
    case journalData
    
    internal func getDataFromType<T: Codable>(instance: UserStartupScreenDayData) -> T? {
        switch self {
        case .moodData:
            let moodData = instance.moodData
            return moodData as? T
        case .sleepData:
            return instance.sleepData as? T
        case .timeSpendData:
            return instance.timeSpendData as? T
        case .medicineData:
            return instance.medicineData as? T
        case .journalData:
            return instance.journalData as? T
        }
    }
}


class PatientLog: Codable {
    var plId: Int = ApplicationSharedInfo.shared.loginResponse?.patientLocationID ?? 0
    var clientId: Int = ApplicationSharedInfo.shared.loginResponse?.clientID ?? 0
    var patientId: Int = ApplicationSharedInfo.shared.loginResponse?.patientID ?? 0
    var moodId: Int = 0
    var sleepHours: Int = 0
    var medicineFlag: Int = 0
    var moodQuestion: String = ""
    var sleepQuestion: String = ""
    var medicineQuestion: String = ""
    var spendQuestion: String = ""
    var spendTime: String = ""
    var journal: String = ""
    var wish: String = ""
    var activityDate: String = ""
    
    init() {
        
    }

    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(plId, forKey: .plId)
        try container.encode(clientId, forKey: .clientId)
        try container.encode(patientId, forKey: .patientId)
        try container.encode(moodId, forKey: .moodId)
        try container.encode(sleepHours, forKey: .sleepHours)
        try container.encode(medicineFlag, forKey: .medicineFlag)
        try container.encode(moodQuestion, forKey: .moodQuestion)
        try container.encode(sleepQuestion, forKey: .sleepQuestion)
        try container.encode(medicineQuestion, forKey: .medicineQuestion)
        try container.encode(spendQuestion, forKey: .spendQuestion)
        try container.encode(spendTime, forKey: .spendTime)
        try container.encode(journal, forKey: .journal)
        try container.encode(wish, forKey: .wish)
        try container.encode(activityDate, forKey: .activityDate)
    }

    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        plId = try container.decode(Int.self, forKey: .plId)
        clientId = try container.decode(Int.self, forKey: .clientId)
        patientId = try container.decode(Int.self, forKey: .patientId)
        moodId = try container.decode(Int.self, forKey: .moodId)
        sleepHours = try container.decode(Int.self, forKey: .sleepHours)
        medicineFlag = try container.decode(Int.self, forKey: .medicineFlag)
        moodQuestion = try container.decode(String.self, forKey: .moodQuestion)
        sleepQuestion = try container.decode(String.self, forKey: .sleepQuestion)
        medicineQuestion = try container.decode(String.self, forKey: .medicineQuestion)
        spendQuestion = try container.decode(String.self, forKey: .spendQuestion)
        spendTime = try container.decode(String.self, forKey: .spendTime)
        journal = try container.decode(String.self, forKey: .journal)
        wish = try container.decode(String.self, forKey: .wish)
        activityDate = try container.decode(String.self, forKey: .activityDate)
    }

    // Coding keys
    enum CodingKeys: String, CodingKey {
        case plId
        case clientId
        case patientId
        case moodId
        case sleepHours
        case medicineFlag
        case moodQuestion
        case sleepQuestion
        case medicineQuestion
        case spendQuestion
        case spendTime
        case journal
        case wish
        case activityDate
    }
}

class SaveUserStartupScreenDetailsRequestForm: EndPointRequest {
    
    var baseURL: String = baseURLString
    var path: String = "patients/api/v1/patientDetails/savePatientStartupScreen"
    var httpMethod: HTTPMethod = .post
    var requestBody: [String : Any]
    
    init?(_ requestParams:PatientLog) {
        guard let reqBody = try? requestParams.toDictionary() else {
            return nil
        }
        print(reqBody)
        self.requestBody = reqBody
    }
}

extension Encodable {
    func toDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dictionary = jsonObject as? [String: Any] else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert JSON to dictionary"])
        }
        return dictionary
    }
}
