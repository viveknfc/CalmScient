//
//  MedicationsAPICodables.swift
//  CalmscientIOS
//
//  Created by NFC on NA.
//

import Foundation

// Define Codable classes to represent the JSON structure

class MedicationDetailsResponse: Codable {
    let response: ResponseDetails
    let totalRecords: Int
    let medicineDetails: [MedicineDetails]

    enum CodingKeys: String, CodingKey {
        case response
        case totalRecords
        case medicineDetails = "medicineDetails"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        response = try container.decode(ResponseDetails.self, forKey: .response)
        totalRecords = try container.decode(Int.self, forKey: .totalRecords)
        medicineDetails = try container.decode([MedicineDetails].self, forKey: .medicineDetails)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(response, forKey: .response)
        try container.encode(totalRecords, forKey: .totalRecords)
        try container.encode(medicineDetails, forKey: .medicineDetails)
    }
}



class MedicineDetails: Codable {
    let date: String
    var medicationDetailsByDate: [MedicationDetailsByDate]
    var isSelected: Bool?

    enum CodingKeys: String, CodingKey {
        case date
        case medicationDetailsByDate = "medicationDetailsByDate"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(String.self, forKey: .date)
        medicationDetailsByDate = try container.decode([MedicationDetailsByDate].self, forKey: .medicationDetailsByDate)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(medicationDetailsByDate, forKey: .medicationDetailsByDate)
    }
}

class MedicationDetailsByDate: Codable {
    let medicineName: String
    let numberOfTablets: Int
    let medicalDetails: MedicalDetails
    let dosageTime: [String]

    enum CodingKeys: String, CodingKey {
        case medicineName
        case numberOfTablets
        case medicalDetails = "medicalDetails"
        case dosageTime
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        medicineName = try container.decode(String.self, forKey: .medicineName)
        numberOfTablets = try container.decode(Int.self, forKey: .numberOfTablets)
        medicalDetails = try container.decode(MedicalDetails.self, forKey: .medicalDetails)
        dosageTime = try container.decode([String].self, forKey: .dosageTime)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(medicineName, forKey: .medicineName)
        try container.encode(numberOfTablets, forKey: .numberOfTablets)
        try container.encode(medicalDetails, forKey: .medicalDetails)
        try container.encode(dosageTime, forKey: .dosageTime)
    }
}

class MedicalDetails: Codable {
    let medicationId: Int
    let medicineName: String //
    let medicineDosage: String //
    let providerName: String? //
    let prescriptionID: Int //
    let providerId: Int?
    let directions: String //
    var scheduledTimeList: [ScheduledTimeList]
    var withMeal: Int //
    var endDate: String //
    var expired: Int?

    enum CodingKeys: String, CodingKey {
        case medicationId
        case medicineName
        case medicineDosage
        case providerName
        case prescriptionID
        case providerId
        case directions
        case scheduledTimeList = "scheduledTimeList"
        case withMeal
        case endDate
        case expired
    }
    
    

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        medicationId = try container.decode(Int.self, forKey: .medicationId)
        medicineName = try container.decode(String.self, forKey: .medicineName)
        medicineDosage = try container.decode(String.self, forKey: .medicineDosage)
        providerName = try container.decodeIfPresent(String.self, forKey: .providerName)
        providerId = try container.decodeIfPresent(Int.self, forKey: .providerId)
        prescriptionID = try container.decode(Int.self, forKey: .prescriptionID)
        directions = try container.decode(String.self, forKey: .directions)
        scheduledTimeList = try container.decode([ScheduledTimeList].self, forKey: .scheduledTimeList)
        withMeal = try container.decode(Int.self, forKey: .withMeal)
        endDate = try container.decode(String.self, forKey: .endDate)
        expired = try container.decodeIfPresent(Int.self, forKey: .expired)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(medicationId, forKey: .medicationId)
        try container.encode(medicineName, forKey: .medicineName)
        try container.encode(medicineDosage, forKey: .medicineDosage)
        try container.encode(providerName, forKey: .providerName)
        try container.encode(providerId, forKey: .providerId)
        try container.encode(prescriptionID, forKey: .prescriptionID)
        try container.encode(directions, forKey: .directions)
        try container.encode(scheduledTimeList, forKey: .scheduledTimeList)
        try container.encode(withMeal, forKey: .withMeal)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(expired, forKey: .expired)
    }
}

class ScheduledTimeList: Codable {
    var scheduledTimes: [MedicationAlarm]//[ScheduledTimes]

    enum CodingKeys: String, CodingKey {
        case scheduledTimes
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        scheduledTimes = try container.decode([MedicationAlarm].self, forKey: .scheduledTimes)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(scheduledTimes, forKey: .scheduledTimes)
    }
}

class ScheduledTimes: Codable { //consumer@care.pluxee.in
    var medicineTime: String //
    var alarmTime: String //
    var alarmId: Int //
    var pmtId: String //
    var medicineTaken: String? //
    var alarmEnabled: String //
    var alarmInterval: String //
    var repeatDay: [String] //repeatDay

    enum CodingKeys: String, CodingKey {
        case medicineTime
        case alarmTime
        case alarmId
        case pmtId
        case medicineTaken
        case alarmEnabled
        case alarmInterval
        case repeatDay = "repeat"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        medicineTime = try container.decode(String.self, forKey: .medicineTime)
        alarmTime = try container.decode(String.self, forKey: .alarmTime)
        alarmId = try container.decode(Int.self, forKey: .alarmId)
        pmtId = try container.decode(String.self, forKey: .pmtId)
        medicineTaken = try container.decodeIfPresent(String.self, forKey: .medicineTaken)
        alarmEnabled = try container.decode(String.self, forKey: .alarmEnabled)
        alarmInterval = try container.decode(String.self, forKey: .alarmInterval)
        repeatDay = try container.decode([String].self, forKey: .repeatDay)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(medicineTime, forKey: .medicineTime)
        try container.encode(alarmTime, forKey: .alarmTime)
        try container.encode(alarmId, forKey: .alarmId)
        try container.encode(pmtId, forKey: .pmtId)
        try container.encode(medicineTaken, forKey: .medicineTaken)
        try container.encode(alarmEnabled, forKey: .alarmEnabled)
        try container.encode(alarmInterval, forKey: .alarmInterval)
        try container.encode(repeatDay, forKey: .repeatDay)
    }
}


//MARK: - ADD Medication

class MedicationAlarm: Codable {
    var medicineTime: String = ""
    var alarmTime: String = "" //new
    var alarmId: Int = 0
    var pmtId: String = "0"
    var medicineTaken: String? //new
    var medicineTakenID: Int?
    var alarmEnabled: String?
    var alarmInterval: String = "" //"05"
    var `repeat`: [String] = []
    
    var alarmDate: String?
    var isEnabled: Int?
    var plId: Int?
    var medicationId: Int?
    var flag: String?
    var isDefault = 1 //0
    
    
    var dayTime:DayTimeValue? = .Morning
    
    
    enum CodingKeys: String, CodingKey {
        case alarmId, alarmInterval, alarmEnabled, medicineTime, pmtId, alarmTime, medicineTaken, medicineTakenID, flag, isEnabled, alarmDate, plId, medicationId, isDefault
        case `repeat` = "repeat"
    }
    
    init?(withScheduledTime:MedicationAlarm, medicationID:Int) { // ScheduledTimes
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            return nil
        }
        let alarmDate = withScheduledTime.alarmTime.getDate(formatString: "yyyy-MM-dd HH:mm:ss")
        plId = userInfo.patientLocationID
        `repeat` = withScheduledTime.repeat
        self.medicationId = medicationID
        self.alarmId = withScheduledTime.alarmId
        self.medicineTime = withScheduledTime.medicineTime
        self.medicineTakenID = withScheduledTime.medicineTakenID
        let isEnableInt = Int(withScheduledTime.alarmEnabled ?? "0")
        self.isEnabled = isEnableInt
        self.alarmInterval = withScheduledTime.alarmInterval
//        self.flag = "I"
        self.alarmDate = Date().dateToString(format: "MM/dd/yyyy")
        self.pmtId = withScheduledTime.pmtId
//        self.medicineTaken = withScheduledTime.medicineTaken
    }
    
    init?(alarmTime2:DayTimeValue) {
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            return nil
        }
        dayTime = alarmTime2
//        alarmTime = Date().dateToString(format: "MM/dd/yyyy")
        switch alarmTime2 {
        case .Morning:
            medicineTime = "06:00:00"
        case .Afternoon:
            medicineTime = "12:00:00"
        case .Evening:
            medicineTime = "18:00:00"
        }
        plId = userInfo.patientLocationID
        `repeat` = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"] : ["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"] // this is the default selection it was [] empty array mentioned if not default needed //
    }
    
    public func getDayTime() -> DayTimeValue {
        return DayTimeValue(rawValue: medicineTime.getDayTimeFromDate(formatter: "HH:mm:ss", includeTimeZone: false) ?? DayTimeValue.Morning.rawValue) ?? DayTimeValue.Morning
    }
    
    public func getTimeRestrictionsFromDate() -> [Date] {
        switch dayTime { // here it was dayTime
        case .Morning:
            let startTimeDate = "06:00:00".createDateFromTimeString()
            let endTimeDate = "11:59:00".createDateFromTimeString()
            return [startTimeDate,endTimeDate]
        case .Afternoon:
            let startTimeDate = "12:00:00".createDateFromTimeString()
            let endTimeDate = "17:59:00".createDateFromTimeString()
            return [startTimeDate,endTimeDate]
        case .Evening:
            let startTimeDate = "18:00:00".createDateFromTimeString()
            let endTimeDate = "23:59:00".createDateFromTimeString()
            return [startTimeDate,endTimeDate]
        case .none:
            return []
        }
    }
    
    func getAlarmIntervalStringValue() -> String {
        if Int(alarmInterval) ?? 0 < 10 {
            return "0\(alarmInterval)"
        } else {
            return "\(alarmInterval)"
        }
    }
    
    func getAlarmTime() -> String? {
        let medicineDateTime = medicineTime.getDate(formatString: "HH:mm:ss")
        let alarmTime = Calendar.current.date(byAdding: .minute, value: -(Int(alarmInterval) ?? 0), to: medicineDateTime)
        print("Alarm Time: \(alarmTime ?? Date().getTomorrowDate())")
        return alarmTime?.dateToString(format: "HH:mm:ss") ?? nil
    }
    
    func getAlarmTimeWithAMOrPM() -> String? {
        let alarmTime = self.getAlarmTime()
        return alarmTime?.getDayTimeFromDate(formatter: "HH:mm:ss", includeTimeZone: true)
    }
    
    func getMedicineTimeWithAMorPM() -> String? {
        return medicineTime.getDayTimeFromDate(formatter: "HH:mm:ss", includeTimeZone: true)
    }
    
    // Custom init method to decode JSON data
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        alarmDate = try container.decodeIfPresent(String.self, forKey: .alarmDate)
        alarmId = try container.decode(Int.self, forKey: .alarmId)
        alarmInterval = try container.decode(String.self, forKey: .alarmInterval)
        plId = try container.decodeIfPresent(Int.self, forKey: .plId)
        pmtId = try container.decode(String.self, forKey: .pmtId)
        medicationId = try container.decodeIfPresent(Int.self, forKey: .medicationId)
        medicineTakenID = try container.decodeIfPresent(Int.self, forKey: .medicineTakenID)
        flag = try container.decodeIfPresent(String.self, forKey: .flag)
        isEnabled = try container.decodeIfPresent(Int.self, forKey: .isEnabled)
        alarmEnabled = try container.decodeIfPresent(String.self, forKey: .alarmEnabled)
        medicineTime = try container.decode(String.self, forKey: .medicineTime)
        `repeat` = try container.decode([String].self, forKey: .repeat)
        medicineTaken = try container.decode(String.self, forKey: .medicineTaken)
        alarmTime = try container.decode(String.self, forKey: .alarmTime)
        isDefault = try container.decode(Int.self, forKey: .isDefault)
    }
    
    // Custom encode method to encode to JSON data
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(alarmDate, forKey: .alarmDate)
        try container.encode(alarmId, forKey: .alarmId)
        try container.encode(alarmInterval, forKey: .alarmInterval)
        try container.encode(plId, forKey: .plId)
        try container.encode(medicationId, forKey: .medicationId)
        try container.encode(medicineTakenID, forKey: .medicineTakenID)
        try container.encode(flag, forKey: .flag)
        try container.encode(pmtId, forKey: .pmtId)
//        try container.encode(alarmEnabled, forKey: .alarmEnabled)
        try container.encode(medicineTime, forKey: .medicineTime)
        try container.encode(`repeat`, forKey: .repeat)
//        try container.encode(alarmTime, forKey: .alarmTime)
//        try container.encode(medicineTaken, forKey: .medicineTaken)
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encode(isDefault, forKey: .isDefault)
    }
}



// Define Codable struct for the main object
class AddMedication: Codable {
    var alarms: [MedicationAlarm] = []
    var direction: String = ""
    var dosage: String = ""
    var endDate: String = ""//Date().getTomorrowDate().dateToString(format: "MM/dd/yyyy")
    var isActive: Int = 1
    var medicationName: String = ""
    var medicineTime: String = ""
    var plId: Int = ApplicationSharedInfo.shared.loginResponse!.patientLocationID
    var prescriptionId: Int = 0
    var patientId: Int = ApplicationSharedInfo.shared.loginResponse!.patientID
    var providerId: Int = 0
    var pvcFlag: String = ""
    var quantity: Int = 1
    var startDate: String = Date().dateToString(format: "MM/dd/yyyy")
    var withMeal: Int = 0
    var provider = ""

    enum CodingKeys: String, CodingKey {
        case alarms, direction, dosage, endDate, isActive, medicationName, medicineTime, plId, prescriptionId, patientId, providerId, pvcFlag, quantity, startDate, withMeal, provider
    }
    
    init() {
        
    }
    
    // Custom init method to decode JSON data
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        alarms = try container.decode([MedicationAlarm].self, forKey: .alarms)
        direction = try container.decode(String.self, forKey: .direction)
        dosage = try container.decode(String.self, forKey: .dosage)
        endDate = try container.decode(String.self, forKey: .endDate)
        isActive = try container.decode(Int.self, forKey: .isActive)
        medicationName = try container.decode(String.self, forKey: .medicationName)
        medicineTime = try container.decode(String.self, forKey: .medicineTime)
        plId = try container.decode(Int.self, forKey: .plId)
        prescriptionId = try container.decode(Int.self, forKey: .prescriptionId)
        patientId = try container.decode(Int.self, forKey: .patientId)
        providerId = try container.decode(Int.self, forKey: .providerId)
        pvcFlag = try container.decode(String.self, forKey: .pvcFlag)
        quantity = try container.decode(Int.self, forKey: .quantity)
        startDate = try container.decode(String.self, forKey: .startDate)
        withMeal = try container.decode(Int.self, forKey: .withMeal)
        provider = try container.decode(String.self, forKey: .provider)
    }

    // Custom encode method to encode to JSON data
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(alarms, forKey: .alarms)
        try container.encode(direction, forKey: .direction)
        try container.encode(dosage, forKey: .dosage)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(medicationName, forKey: .medicationName)
        try container.encode(medicineTime, forKey: .medicineTime)
        try container.encode(plId, forKey: .plId)
        try container.encode(prescriptionId, forKey: .prescriptionId)
        try container.encode(patientId, forKey: .patientId)
        try container.encode(providerId, forKey: .providerId)
        try container.encode(pvcFlag, forKey: .pvcFlag)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(withMeal, forKey: .withMeal)
        try container.encode(provider, forKey: .provider)
    }
}

class AddMedicationSavedResponse: Codable {
    let response: ResponseDetails
    
    enum CodingKeys: String, CodingKey {
        case response
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        response = try container.decode(ResponseDetails.self, forKey: .response)
    }
    
    // Encode method to encode JSON data
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(response, forKey: .response)
    }
    
}

class GetMedicationsRequestForm: EndPointRequest {
    var baseURL: String = baseURLString
    var path: String = "patients/api/v1/medications/getMedications"
    var httpMethod: HTTPMethod = .post
    var requestBody: [String : Any]
    
    required init(_ requestBodyParams:[String:Any]) {
        self.requestBody = requestBodyParams
    }
}


class AddMedicationsRequestForm: EndPointRequest {
    
    var baseURL: String = baseURLString
    var path: String = "patients/api/v1/medications/addMedications"
    var httpMethod: HTTPMethod = .post
    var requestBody: [String : Any] = [:]
    var jsonData:Data? = nil
    
    required init(_ requestData:Data?) {
        self.jsonData = requestData
    }
    
    func getURLRequest() -> URLRequest? {
        
        guard let url = URL(string: "\(baseURL)\(path)"), jsonData != nil else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = self.httpMethod.rawValue
        
        for keyValuePair in self.headers {
            request.setValue(keyValuePair.value, forHTTPHeaderField: keyValuePair.key)
        }
        request.httpBody = jsonData
        
        return request
    }
}

class UpdateMedicationsAlarmRequestForm: EndPointRequest {
    var baseURL: String = baseURLString
    var path: String = "patients/api/v1/medications/addPatientMedicationAlarms"
    var httpMethod: HTTPMethod = .post
    var requestBody: [String : Any] = [:]
    var jsonData:Data? = nil
    
    required init(_ requestData:Data?) {
        self.jsonData = requestData
    }
    
    func getURLRequest() -> URLRequest? {
        
        guard let url = URL(string: "\(baseURL)\(path)"), jsonData != nil else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = self.httpMethod.rawValue
        
        for keyValuePair in self.headers {
            request.setValue(keyValuePair.value, forHTTPHeaderField: keyValuePair.key)
        }
        request.httpBody = jsonData
        
        return request
    }
}

class OnlyMedicationAlarm:Codable {
    var alarms: [MedicationAlarm] = []
    
    enum CodingKeys: String, CodingKey {
        case alarms
    }
    init() {
        
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        alarms = try container.decode([MedicationAlarm].self, forKey: .alarms)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(alarms, forKey: .alarms)
    }
}
