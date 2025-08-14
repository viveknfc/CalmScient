//
//  CourseAPICodables.swift
//  CalmscientIOS
//
//  Created by KA on NA.
//

import Foundation


// Codable structure for chapters
class CourseChapter: Codable {
    let chapterId: Int
    let chapterName: String
    let chapterUrl: String?
    let isCourseCompleted: Int
    let pageCount: Int
    let imageUrl: String
    let chapterOnlyReading: Bool
    
    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(chapterId, forKey: .chapterId)
        try container.encode(chapterName, forKey: .chapterName)
        try container.encodeIfPresent(chapterUrl, forKey: .chapterUrl)
        try container.encode(isCourseCompleted, forKey: .isCourseCompleted)
        try container.encode(pageCount, forKey: .pageCount)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(chapterOnlyReading, forKey: .chapterOnlyReading)
    }
    
    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        chapterId = try container.decode(Int.self, forKey: .chapterId)
        chapterName = try container.decode(String.self, forKey: .chapterName)
        chapterUrl = try container.decodeIfPresent(String.self, forKey: .chapterUrl)
        isCourseCompleted = try container.decode(Int.self, forKey: .isCourseCompleted)
        pageCount = try container.decode(Int.self, forKey: .pageCount)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        chapterOnlyReading = try container.decode(Bool.self, forKey: .chapterOnlyReading)
    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case chapterId
        case chapterName
        case chapterUrl
        case isCourseCompleted
        case pageCount
        case imageUrl
        case chapterOnlyReading
    }
}

// Codable structure for lessons
class CourseLesson: Codable {
    let lessonId: Int
    let lessonName: String
    let chapters: [CourseChapter]
    
    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lessonId, forKey: .lessonId)
        try container.encode(lessonName, forKey: .lessonName)
        try container.encode(chapters, forKey: .chapters)
    }
    
    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lessonId = try container.decode(Int.self, forKey: .lessonId)
        lessonName = try container.decode(String.self, forKey: .lessonName)
        chapters = try container.decode([CourseChapter].self, forKey: .chapters)
    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case lessonId
        case lessonName
        case chapters
    }
}


// Codable structure for the main managing anxiety data
class UserCoursesData: Codable {
    let statusResponse: ResponseDetails
    let coursesList: [CourseLesson]
    let patientSessionDetails: PatientSessionDetails
    
    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(statusResponse, forKey: .statusResponse)
        try container.encode(coursesList, forKey: .coursesList)
        try container.encode(patientSessionDetails, forKey: .patientSessionDetails)
        
    }
    
    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        statusResponse = try container.decode(ResponseDetails.self, forKey: .statusResponse)
        coursesList = try container.decode([CourseLesson].self, forKey: .coursesList)
        patientSessionDetails = try container.decode(PatientSessionDetails.self, forKey: .patientSessionDetails)
    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case statusResponse
        case coursesList = "managingAnxiety"
        case patientSessionDetails
    }
}


class GetCourseDetailsRequestForm: EndPointRequest {
    
    var baseURL: String = baseURLString
    var path: String = "patients/api/v1/course/getPatientCourseIndex"
    var httpMethod: HTTPMethod = .post
    var requestBody: [String : Any]
    
    required init(_ requestBodyParams:[String:Any]) {
        self.requestBody = requestBodyParams
    }
}



class PatientSessionDetails: Codable {
    let userSessionID: String
    let languageId: Int
    let languageName: String
    let darkTheme: Int
    let lightTheme: Int
    
    enum CodingKeys: CodingKey {
        case userSessionID
        case languageId
        case languageName
        case darkTheme
        case lightTheme
    }
    
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userSessionID, forKey: .userSessionID)
        try container.encode(self.languageId, forKey: .languageId)
        try container.encode(self.languageName, forKey: .languageName)
        try container.encode(self.darkTheme, forKey: .darkTheme)
        try container.encode(self.lightTheme, forKey: .lightTheme)
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userSessionID = try container.decode(String.self, forKey: .userSessionID)
        self.languageId = try container.decode(Int.self, forKey: .languageId)
        self.languageName = try container.decode(String.self, forKey: .languageName)
        self.darkTheme = try container.decode(Int.self, forKey: .darkTheme)
        self.lightTheme = try container.decode(Int.self, forKey: .lightTheme)
    }
}
