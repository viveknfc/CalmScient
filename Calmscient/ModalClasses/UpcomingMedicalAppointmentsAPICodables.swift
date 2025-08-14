//
//  UpcomingMedicalAppointmentsAPICodables.swift
//  CalmscientIOS
//
//  Created by KA on NA.
//

import Foundation

class MedicalAppointmentResponse: Codable {
    let statusResponse: ResponseDetails
    let appointmentDetailsList: [MedicalAppointmentDetailsList]
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.statusResponse = try container.decode(ResponseDetails.self, forKey: .statusResponse)
        self.appointmentDetailsList = try container.decode([MedicalAppointmentDetailsList].self, forKey: .appointmentDetailsList)
    }
    
    enum CodingKeys: String, CodingKey {
        case statusResponse
        case appointmentDetailsList
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.statusResponse, forKey: .statusResponse)
        try container.encode(self.appointmentDetailsList, forKey: .appointmentDetailsList)
    }
}


class MedicalAppointmentDetailsList: Codable {
    let date: String
    let appointmentDetailsByDate: [MedicalAppointmentDetailsByDate]
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.date = try container.decode(String.self, forKey: .date)
        self.appointmentDetailsByDate = try container.decode([MedicalAppointmentDetailsByDate].self, forKey: .appointmentDetailsByDate)
    }
    
    enum CodingKeys: String, CodingKey {
        case date
        case appointmentDetailsByDate
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.date, forKey: .date)
        try container.encode(self.appointmentDetailsByDate, forKey: .appointmentDetailsByDate)
    }
}

class MedicalAppointmentDetailsByDate: Codable {
    let hospitalName: String
    let appointmentDetails: MedicalAppointmentDetails
    var dateString:String? = nil
    var showDateLabel: Bool = true
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.hospitalName = try container.decode(String.self, forKey: .hospitalName)
        self.appointmentDetails = try container.decode(MedicalAppointmentDetails.self, forKey: .appointmentDetails)
    }
    
    enum CodingKeys: String, CodingKey {
        case hospitalName
        case appointmentDetails
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.hospitalName, forKey: .hospitalName)
        try container.encode(self.appointmentDetails, forKey: .appointmentDetails)
    }
}

class MedicalAppointmentDetails: Codable {
    let appointmentId: Int
    let providerName: String
    let patientName: String?
    let hospitalName: String
    let dateAndTime: String
    let contact: String?
    let address: String?
    let appointmentDetails: String
    let alert: Int?
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.appointmentId = try container.decode(Int.self, forKey: .appointmentId)
        self.providerName = try container.decode(String.self, forKey: .providerName)
        self.patientName = try container.decodeIfPresent(String.self, forKey: .patientName)
        self.hospitalName = try container.decode(String.self, forKey: .hospitalName)
        self.dateAndTime = try container.decode(String.self, forKey: .dateAndTime)
        self.contact = try container.decodeIfPresent(String.self, forKey: .contact)
        self.address = try container.decodeIfPresent(String.self, forKey: .address)
        self.appointmentDetails = try container.decode(String.self, forKey: .appointmentDetails)
        self.alert = try container.decodeIfPresent(Int.self, forKey: .alert)
    }
    
    enum CodingKeys: String, CodingKey {
        case appointmentId
        case providerName
        case patientName
        case hospitalName
        case dateAndTime
        case contact
        case address
        case appointmentDetails
        case alert
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.appointmentId, forKey: .appointmentId)
        try container.encode(self.providerName, forKey: .providerName)
        try container.encodeIfPresent(self.patientName, forKey: .patientName)
        try container.encode(self.hospitalName, forKey: .hospitalName)
        try container.encode(self.dateAndTime, forKey: .dateAndTime)
        try container.encodeIfPresent(self.contact, forKey: .contact)
        try container.encodeIfPresent(self.address, forKey: .address)
        try container.encode(self.appointmentDetails, forKey: .appointmentDetails)
        try container.encodeIfPresent(self.alert, forKey: .alert)
    }
}

class GetUserMedicalAppointmentsRequestForm: EndPointRequest {
    
    var baseURL: String = baseURLString
    var path: String = "patients/api/v1/patientDetails/getMedicalAppointmentsByPatientId"
    var httpMethod: HTTPMethod = .post
    var requestBody: [String : Any]
    
    required init(_ requestBodyParams:[String:Any]) {
        self.requestBody = requestBodyParams
    }
}
