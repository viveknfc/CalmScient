//
//  ScreeningsAPICodables.swift
//  CalmscientIOS
//
//  Created by NFC on NA.
//

import Foundation

public let baseURLString:String = "https://calmscient.centralindia.cloudapp.azure.com:8090/"

//MARK: - Screening List (Main Page)

class Screening: Codable {
    let startDate: String?
    let score: Int
    let completionDate: String?
    let plid: Int
    let patientID: Int
    let screeningID: Int
    let screeningType: String
    let assessmentID: Int
    let archiveFlag: Int
    let clientID: Int
    let screeningStatus: String
    let screeningReminder: String?
    
    enum CodingKeys: CodingKey {
        case startDate
        case score
        case completionDate
        case plid
        case patientID
        case screeningID
        case screeningType
        case assessmentID
        case archiveFlag
        case clientID
        case screeningStatus
        case screeningReminder
    }
    
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.startDate = try container.decodeIfPresent(String.self, forKey: .startDate)
        self.score = try container.decode(Int.self, forKey: .score)
        self.completionDate = try container.decodeIfPresent(String.self, forKey: .completionDate)
        self.plid = try container.decode(Int.self, forKey: .plid)
        self.patientID = try container.decode(Int.self, forKey: .patientID)
        self.screeningID = try container.decode(Int.self, forKey: .screeningID)
        self.screeningType = try container.decode(String.self, forKey: .screeningType)
        self.assessmentID = try container.decode(Int.self, forKey: .assessmentID)
        self.archiveFlag = try container.decode(Int.self, forKey: .archiveFlag)
        self.clientID = try container.decode(Int.self, forKey: .clientID)
        self.screeningStatus = try container.decode(String.self, forKey: .screeningStatus)
        self.screeningReminder = try container.decodeIfPresent(String.self, forKey: .screeningReminder)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.startDate, forKey: .startDate)
        try container.encode(self.score, forKey: .score)
        try container.encodeIfPresent(self.completionDate, forKey: .completionDate)
        try container.encode(self.plid, forKey: .plid)
        try container.encode(self.patientID, forKey: .patientID)
        try container.encode(self.screeningID, forKey: .screeningID)
        try container.encode(self.screeningType, forKey: .screeningType)
        try container.encode(self.assessmentID, forKey: .assessmentID)
        try container.encode(self.archiveFlag, forKey: .archiveFlag)
        try container.encode(self.clientID, forKey: .clientID)
        try container.encode(self.screeningStatus, forKey: .screeningStatus)
        try container.encodeIfPresent(self.screeningReminder, forKey: .screeningReminder)
    }
    
}

class ScreeningResponse: Codable {
    let statusResponse: ResponseDetails
    let screeningList: [Screening]
    
    enum CodingKeys: CodingKey {
        case statusResponse
        case screeningList
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.statusResponse = try container.decode(ResponseDetails.self, forKey: .statusResponse)
        self.screeningList = try container.decode([Screening].self, forKey: .screeningList)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.statusResponse, forKey: .statusResponse)
        try container.encode(self.screeningList, forKey: .screeningList)
    }
}

//MARK: - Screening Answers

class PatientAnswer: Codable {
    var flag: String
    var answerId: Int
    var screeningId: Int
    var patientLocationId: Int
    var questionnaireId: Int
    var optionId: Int
    var score: Int
    var clientId: Int
    var patientId: Int
    var assessmentId: Int
    
    enum CodingKeys: String, CodingKey {
        case flag, answerId, screeningId, patientLocationId, questionnaireId, optionId, score, clientId, patientId, assessmentId
    }
    
    init?(from questionarie:QuestionnaireItem, loginDetails:LoginDetails, screening:Screening ,selectedAnswerIndex:Int = -1, AnswerID:String?) {
        if questionarie.answerResponse.indices.contains(selectedAnswerIndex) {
            let selectedResponse = questionarie.answerResponse[selectedAnswerIndex]
            self.score = Int(selectedResponse.optionScore) ?? 0
            self.optionId = Int(selectedResponse.optionLabelId)
            self.answerId = Int(AnswerID ?? "0") ?? 0
        } else {
           return nil
        }
        self.flag = "I"
        self.patientLocationId = loginDetails.patientLocationID
        self.patientId = loginDetails.patientID
        self.clientId = loginDetails.clientID
        self.assessmentId = screening.assessmentID
        self.screeningId = screening.screeningID
        self.questionnaireId = questionarie.questionId
        
        
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        flag = try container.decode(String.self, forKey: .flag)
        answerId = try container.decode(Int.self, forKey: .answerId)
        screeningId = try container.decode(Int.self, forKey: .screeningId)
        patientLocationId = try container.decode(Int.self, forKey: .patientLocationId)
        questionnaireId = try container.decode(Int.self, forKey: .questionnaireId)
        optionId = try container.decode(Int.self, forKey: .optionId)
        score = try container.decode(Int.self, forKey: .score)
        clientId = try container.decode(Int.self, forKey: .clientId)
        patientId = try container.decode(Int.self, forKey: .patientId)
        assessmentId = try container.decode(Int.self, forKey: .assessmentId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(flag, forKey: .flag)
        try container.encode(answerId, forKey: .answerId)
        try container.encode(screeningId, forKey: .screeningId)
        try container.encode(patientLocationId, forKey: .patientLocationId)
        try container.encode(questionnaireId, forKey: .questionnaireId)
        try container.encode(optionId, forKey: .optionId)
        try container.encode(score, forKey: .score)
        try container.encode(clientId, forKey: .clientId)
        try container.encode(patientId, forKey: .patientId)
        try container.encode(assessmentId, forKey: .assessmentId)
    }
}

//MARK: - Screening Questions

class AnswerResponse: Codable {
    let optionLabelId: Int
    let optionLabel: String
    let optionScore: String
    let answer: String?
    let answerId: String?
    var selected: String
    
    enum CodingKeys: String, CodingKey {
        case optionLabelId, optionLabel, optionScore, answer, answerId, selected
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        optionLabelId = try container.decode(Int.self, forKey: .optionLabelId)
        optionLabel = try container.decode(String.self, forKey: .optionLabel)
        optionScore = try container.decode(String.self, forKey: .optionScore)
        answer = try container.decodeIfPresent(String.self, forKey: .answer)
        answerId = try container.decodeIfPresent(String.self, forKey: .answerId)
        selected = try container.decode(String.self, forKey: .selected)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(optionLabelId, forKey: .optionLabelId)
        try container.encode(optionLabel, forKey: .optionLabel)
        try container.encode(optionScore, forKey: .optionScore)
        try container.encode(answer, forKey: .answer)
        try container.encode(answerId, forKey: .answerId)
        try container.encode(selected, forKey: .selected)
    }
}

class QuestionnaireItem: Codable {
    let questionNo: Int
    let questionId: Int
    let questionName: String
    let optionTypeId: String
    let optionType: String
    let answerResponse: [AnswerResponse]
    
    enum CodingKeys: String, CodingKey {
        case questionNo, questionId, questionName, optionTypeId, optionType, answerResponse
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        questionNo = try container.decode(Int.self, forKey: .questionNo)
        questionId = try container.decode(Int.self, forKey: .questionId)
        questionName = try container.decode(String.self, forKey: .questionName)
        optionTypeId = try container.decode(String.self, forKey: .optionTypeId)
        optionType = try container.decode(String.self, forKey: .optionType)
        answerResponse = try container.decode([AnswerResponse].self, forKey: .answerResponse)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(questionNo, forKey: .questionNo)
        try container.encode(questionId, forKey: .questionId)
        try container.encode(questionName, forKey: .questionName)
        try container.encode(optionTypeId, forKey: .optionTypeId)
        try container.encode(optionType, forKey: .optionType)
        try container.encode(answerResponse, forKey: .answerResponse)
    }
}

class QuestionnaireResponse: Codable {
    let statusResponse: ResponseDetails
    let questionnaire: [QuestionnaireItem]
    
    enum CodingKeys: String, CodingKey {
        case statusResponse
        case questionnaire
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        statusResponse = try container.decode(ResponseDetails.self, forKey: .statusResponse)
        questionnaire = try container.decode([QuestionnaireItem].self, forKey: .questionnaire)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(statusResponse, forKey: .statusResponse)
        try container.encode(questionnaire, forKey: .questionnaire)
    }
}


//MARK: - Screening Results
class ScreeningResults: Codable {
    let patientID: Int
    let firstName: String
    let lastName: String
    let patientAccountNumber: Int
    let screeningName: String
    let screeningId: Int
    let screeningDate: String
    let score: Int
    let total: Int
    let averageResult: String
    let screeningReminder: String
    let assessmentId: Int
    
    enum CodingKeys: String, CodingKey {
        case patientID, firstName, lastName, patientAccountNumber, screeningName, screeningId, screeningDate, score, total, averageResult, screeningReminder, assessmentId
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        patientID = try container.decode(Int.self, forKey: .patientID)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        patientAccountNumber = try container.decode(Int.self, forKey: .patientAccountNumber)
        screeningName = try container.decode(String.self, forKey: .screeningName)
        screeningId = try container.decode(Int.self, forKey: .screeningId)
        screeningDate = try container.decode(String.self, forKey: .screeningDate)
        score = try container.decode(Int.self, forKey: .score)
        total = try container.decode(Int.self, forKey: .total)
        averageResult = try container.decode(String.self, forKey: .averageResult)
        screeningReminder = try container.decode(String.self, forKey: .screeningReminder)
        assessmentId = try container.decode(Int.self, forKey: .assessmentId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(patientID, forKey: .patientID)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(patientAccountNumber, forKey: .patientAccountNumber)
        try container.encode(screeningName, forKey: .screeningName)
        try container.encode(screeningId, forKey: .screeningId)
        try container.encode(screeningDate, forKey: .screeningDate)
        try container.encode(score, forKey: .score)
        try container.encode(total, forKey: .total)
        try container.encode(averageResult, forKey: .averageResult)
        try container.encode(screeningReminder, forKey: .screeningReminder)
        try container.encode(assessmentId, forKey: .assessmentId)
    }
}

class ScreeningResultsResponse: Codable {
    let statusResponse: ResponseDetails
    let screeningResults: ScreeningResults
    
    enum CodingKeys: String, CodingKey {
        case statusResponse
        case screeningResults
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        statusResponse = try container.decode(ResponseDetails.self, forKey: .statusResponse)
        screeningResults = try container.decode(ScreeningResults.self, forKey: .screeningResults)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(statusResponse, forKey: .statusResponse)
        try container.encode(screeningResults, forKey: .screeningResults)
    }
}

//MARK: - Screening History
class ScreeningHistory: Codable {
    let score: Int
    let completionDateTime: String
    let screeningID: Int
    let screeningType: String
    let assessmentID: Int
    let totalScore: Int
    
    enum CodingKeys: String, CodingKey {
        case score, completionDateTime, screeningID, screeningType, assessmentID, totalScore
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        score = try container.decode(Int.self, forKey: .score)
        completionDateTime = try container.decode(String.self, forKey: .completionDateTime)
        screeningID = try container.decode(Int.self, forKey: .screeningID)
        screeningType = try container.decode(String.self, forKey: .screeningType)
        assessmentID = try container.decode(Int.self, forKey: .assessmentID)
        totalScore = try container.decode(Int.self, forKey: .totalScore)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(score, forKey: .score)
        try container.encode(completionDateTime, forKey: .completionDateTime)
        try container.encode(screeningID, forKey: .screeningID)
        try container.encode(screeningType, forKey: .screeningType)
        try container.encode(assessmentID, forKey: .assessmentID)
        try container.encode(totalScore, forKey: .totalScore)
    }
}

class ScreeningHistoryResponse: Codable {
    let statusResponse: ResponseDetails
    let screeningHistory: [ScreeningHistory]
    
    enum CodingKeys: String, CodingKey {
        case statusResponse, screeningHistory
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        statusResponse = try container.decode(ResponseDetails.self, forKey: .statusResponse)
        screeningHistory = try container.decode([ScreeningHistory].self, forKey: .screeningHistory)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(statusResponse, forKey: .statusResponse)
        try container.encode(screeningHistory, forKey: .screeningHistory)
    }
}

//MARK: - Screening Answers Server Response

struct ScreeningAnswersSavedResponse: Codable {
    let statusResponse: ResponseDetails
    let totalAnswers: Int
    
    enum CodingKeys: String, CodingKey {
        case statusResponse, totalAnswers
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        statusResponse = try container.decode(ResponseDetails.self, forKey: .statusResponse)
        totalAnswers = try container.decode(Int.self, forKey: .totalAnswers)
    }
    
    // Encode method to encode JSON data
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(statusResponse, forKey: .statusResponse)
        try container.encode(totalAnswers, forKey: .totalAnswers)
    }
    
}
//MARK: - Screening results

class ScreeningSuccessResults: Codable {
    let patientID: Int
    let firstName: String
    let lastName: String
    let patientAccountNumber: Int
    let screeningName: String
    let screeningId: Int
    let screeningDate: String
    let score: Int
    let total: Int
    let averageResult: String
    let screeningReminder: String
    let assessmentId: Int
    
    enum CodingKeys: String, CodingKey {
        case patientID
        case firstName
        case lastName
        case patientAccountNumber
        case screeningName
        case screeningId
        case screeningDate
        case score
        case total
        case averageResult
        case screeningReminder
        case assessmentId
    }
    
    // Custom initializer for decoding
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        patientID = try container.decode(Int.self, forKey: .patientID)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        patientAccountNumber = try container.decode(Int.self, forKey: .patientAccountNumber)
        screeningName = try container.decode(String.self, forKey: .screeningName)
        screeningId = try container.decode(Int.self, forKey: .screeningId)
        screeningDate = try container.decode(String.self, forKey: .screeningDate)
        score = try container.decode(Int.self, forKey: .score)
        total = try container.decode(Int.self, forKey: .total)
        averageResult = try container.decode(String.self, forKey: .averageResult)
        screeningReminder = try container.decode(String.self, forKey: .screeningReminder)
        assessmentId = try container.decode(Int.self, forKey: .assessmentId)
    }
    
    // Encoding method
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(patientID, forKey: .patientID)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(patientAccountNumber, forKey: .patientAccountNumber)
        try container.encode(screeningName, forKey: .screeningName)
        try container.encode(screeningId, forKey: .screeningId)
        try container.encode(screeningDate, forKey: .screeningDate)
        try container.encode(score, forKey: .score)
        try container.encode(total, forKey: .total)
        try container.encode(averageResult, forKey: .averageResult)
        try container.encode(screeningReminder, forKey: .screeningReminder)
        try container.encode(assessmentId, forKey: .assessmentId)
    }
}

class ScreeningSuccessResponse: Codable {

    let statusResponse: ResponseDetails
    let screeningResults: ScreeningSuccessResults
    
    // Coding keys for ScreeningResponse struct
    private enum CodingKeys: String, CodingKey {
        case statusResponse
        case screeningResults
    }
    
    // Custom initializer for decoding
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        statusResponse = try container.decode(ResponseDetails.self, forKey: .statusResponse)
        screeningResults = try container.decode(ScreeningSuccessResults.self, forKey: .screeningResults)
    }
    
    // Encoding method
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(statusResponse, forKey: .statusResponse)
        try container.encode(screeningResults, forKey: .screeningResults)
    }
}

//MARK: - Screening URL request.

class ScreeningListRequestForm: EndPointRequest {
    var baseURL: String = baseURLString
    var path: String = "patients/api/v1/screening/getScreeningListForMobile"
    var httpMethod: HTTPMethod = .post
    var requestBody: [String : Any] {
        guard let loginResponse = ApplicationSharedInfo.shared.loginResponse else {
            return [:]
        }
        return ["patientId":loginResponse.patientID,"clientId":loginResponse.clientID,"patientLocationId":loginResponse.patientLocationID]
    }
}



class ScreeningQuestionarieForm: EndPointRequest {
    var baseURL: String = baseURLString
    
    var path: String = "patients/api/v1/screening/getScreeningQuestionnaireForMobile"
    
    var httpMethod: HTTPMethod = .post
    
    var requestBody: [String : Any]
    
    required init(_ requestBodyParams:[String:Any]) {
        self.requestBody = requestBodyParams
    }
}

class ScreeningHistoryRequestForm: EndPointRequest {
    
    var baseURL: String = baseURLString
    var path: String = "patients/api/v1/screening/getScreeningHistoryForMobile"
    var httpMethod: HTTPMethod = .post
    var requestBody: [String : Any]
    
    required init(_ requestBodyParams:[String:Any]) {
        self.requestBody = requestBodyParams
    }
}

class ScreeningAnswersSavedRequestForm: EndPointRequest {
    var baseURL: String = baseURLString
    var path: String = "patients/api/v1/screening/savePatientAnswersForMobile"
    var httpMethod: HTTPMethod = .post
    var requestBody: [String : Any]
    
    required init(_ requestBodyParams:[String: Any]) {
        self.requestBody = requestBodyParams
    }
}

class ScreeningSuccessResultRequestForm: EndPointRequest {
    var baseURL: String = baseURLString
    var path: String = "patients/api/v1/screening/getScreeningResultsForMobile"
    var httpMethod: HTTPMethod = .post
    var requestBody: [String : Any]
    
    required init(_ requestBodyParams:[String: Any]) {
        self.requestBody = requestBodyParams
    }
}
