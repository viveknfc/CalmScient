//
//  CodableAPICodables.swift
//  CalmscientIOS
//
//  Created by KA on 25/05/24.
//

import Foundation

public enum CodableType {
    case Mood
    case Sleep
    case PHQ9
    case GAD7
    case Audit
    case DAST
    case ProgressOfCourseWork
    case JournalEntry
    
    func getInstanceTypeFromCodable() -> Codable.Type {
        switch self {
        case .Mood:
            return SummaryOfMood.self
        case .Sleep:
            return SummaryOfSleep.self
        case .PHQ9:
            return SummaryOfPHQ9.self
        case .GAD7:
            return SummaryOfGAD7.self
        case .Audit:
            return SummaryOfAudit.self
        case .DAST:
            return SummaryOfDAST.self
        case .ProgressOfCourseWork:
            return SummaryOfMood.self
        case .JournalEntry:
            return SummaryOfMood.self
        }
    }
}


public class GraphData {
    let yValue:Int
    let xValue:String
    let additionalInfo:String?
    var graphDataType:WeeklySummaryItems
    
    init(yAxisValue: Int, xAxisValue: String, additionalInfo: String?, graphType:WeeklySummaryItems) {
        self.xValue = xAxisValue
        self.yValue = yAxisValue
        self.additionalInfo = additionalInfo
        self.graphDataType = graphType
    }
    
    func getYAxisLabelValue() -> String? {
        guard  graphDataType == .WeeklySummarySummaryOfMood else {
            return nil
        }
        switch yValue {
            case 5: return "EXCELLENT"
            case 3: return "FAIR"
            case 2: return "COULD BE\n BETTER"
            case 1: return "BAD"
            case 4: return "GOOD"
            default: return nil
        }
    }
    
    func getMarkerTextValue() -> String {
        let scoreString = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Score" : "Puntaje"
        guard let additionalInfo = self.additionalInfo else {
            return "\(scoreString)(\(yValue))"
        }
        return "\(scoreString)(\(yValue))\n\(additionalInfo)"
    }
    
    func getXAxisLabelValue() -> String {
        let date = xValue.getDate(formatString: "yyyy-MM-dd")
        let monthAndDayValue = getFormattedMonthAndDay(from: date)
        return "\(monthAndDayValue.day)\n\(getMonthShortForm(value: Int(monthAndDayValue.month) ?? -1))"
    }
    
    func barchartgetXAxisLabelValue() -> String? {
        guard  graphDataType == .WeeklySummarySummaryOfMood else {
            return nil
        }
        switch yValue {
            case 1: return "EXCELLENT"
            case 2: return "FAIR"
            case 3: return "COULD BE\n BETTER"
            case 4: return "BAD"
            case 5: return "GOOD"
            default: return nil
        }
    }
    
    private func getMonthShortForm(value:Int) -> String {
        var dateComponents = DateComponents()
        dateComponents.month = value
        
        let calendar = Calendar.current
        if let date = calendar.date(from: dateComponents) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM"
            dateFormatter.locale = Locale(identifier: Utility.shared.getLocaleIdentifier())
            let outputMonthString = dateFormatter.string(from: date)
            return outputMonthString
        } else {
            return ""
        }
    }
    
    private func getFormattedMonthAndDay(from date: Date) -> (month: String, day: String) {
        let dateFormatter = DateFormatter()
        
        // Format for month
        dateFormatter.dateFormat = "MM"
        let monthString = dateFormatter.string(from: date)
        
        // Format for day
        dateFormatter.dateFormat = "dd"
        let dayString = dateFormatter.string(from: date)
        
        return (month: monthString, day: dayString)
    }

}


//MARK: - Summary Of Mood

class MoodData: Codable {
    let plId: Int
    let moodStatusId: Int
    let moodScore: Int
    let createdAt: String
    let mood: String
    let sno: Int
    
    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(plId, forKey: .plId)
        try container.encode(moodStatusId, forKey: .moodStatusId)
        try container.encode(moodScore, forKey: .moodScore)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(mood, forKey: .mood)
        try container.encode(sno, forKey: .sno)
    }
    
    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        plId = try container.decode(Int.self, forKey: .plId)
        moodStatusId = try container.decode(Int.self, forKey: .moodStatusId)
        moodScore = try container.decode(Int.self, forKey: .moodScore)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        mood = try container.decode(String.self, forKey: .mood)
        sno = try container.decode(Int.self, forKey: .sno)
    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case plId
        case moodStatusId
        case moodScore
        case createdAt
        case mood
        case sno
    }
    
    func getGraphData() -> GraphData {
        return GraphData(yAxisValue: self.moodScore, xAxisValue: self.createdAt, additionalInfo: self.mood, graphType: .WeeklySummarySummaryOfMood)
    }
}

class SummaryOfMood: Codable {
    let response: ResponseDetails
    let averageMood: String
    let moodMonitorList: [MoodData]
    
    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(response, forKey: .response)
        try container.encode(averageMood, forKey: .averageMood)
        try container.encode(moodMonitorList, forKey: .moodMonitorList)
    }
    
    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        response = try container.decode(ResponseDetails.self, forKey: .response)
        averageMood = try container.decode(String.self, forKey: .averageMood)
        moodMonitorList = try container.decode([MoodData].self, forKey: .moodMonitorList)
    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case response
        case averageMood
        case moodMonitorList
    }
}


//MARK: - Summary Of Sleep
class SleepData: Codable {
    let plId: Int
    let sleepHours: Double
    let createdAt: String
    let sno: Int
    
    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(plId, forKey: .plId)
        try container.encode(sleepHours, forKey: .sleepHours)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(sno, forKey: .sno)
    }
    
    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        plId = try container.decode(Int.self, forKey: .plId)
        sleepHours = try container.decode(Double.self, forKey: .sleepHours)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        sno = try container.decode(Int.self, forKey: .sno)
    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case plId
        case sleepHours
        case createdAt
        case sno
    }
    
    func getGraphData() -> GraphData {
        return GraphData(yAxisValue: Int(self.sleepHours), xAxisValue: self.createdAt, additionalInfo: nil, graphType: .WeeklySummarySummaryOfSleep)
    }
}



class SummaryOfSleep: Codable {
    let statusResponse: ResponseDetails
    let avgTime: Int
    let sleepMonitorList: [SleepData]
    
    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(statusResponse, forKey: .statusResponse)
        try container.encode(avgTime, forKey: .avgTime)
        try container.encode(sleepMonitorList, forKey: .sleepMonitorList)
    }
    
    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        statusResponse = try container.decode(ResponseDetails.self, forKey: .statusResponse)
        avgTime = try container.decode(Int.self, forKey: .avgTime)
        sleepMonitorList = try container.decode([SleepData].self, forKey: .sleepMonitorList)
    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case statusResponse
        case avgTime
        case sleepMonitorList
    }
}

//MARK: - Summary Of PHQ9

class PHQ9Data: Codable {
    let screeningId: Int
    let plId: Int
    let score: Int
    let screening: String
    let firstName: String
    let lastName: String
    let scoreTitle: String
    let startDate: String
    let completionDate: String
    let pscreeningId: Int
    
    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(screeningId, forKey: .screeningId)
        try container.encode(plId, forKey: .plId)
        try container.encode(score, forKey: .score)
        try container.encode(screening, forKey: .screening)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(scoreTitle, forKey: .scoreTitle)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(completionDate, forKey: .completionDate)
        try container.encode(pscreeningId, forKey: .pscreeningId)
    }
    
    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        screeningId = try container.decode(Int.self, forKey: .screeningId)
        plId = try container.decode(Int.self, forKey: .plId)
        score = try container.decode(Int.self, forKey: .score)
        screening = try container.decode(String.self, forKey: .screening)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        scoreTitle = try container.decode(String.self, forKey: .scoreTitle)
        startDate = try container.decode(String.self, forKey: .startDate)
        completionDate = try container.decode(String.self, forKey: .completionDate)
        pscreeningId = try container.decode(Int.self, forKey: .pscreeningId)
    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case screeningId
        case plId
        case score
        case screening
        case firstName
        case lastName
        case scoreTitle
        case startDate
        case completionDate
        case pscreeningId
    }
    
    func getGraphData() -> GraphData {
        return GraphData(yAxisValue: self.score, xAxisValue: self.completionDate, additionalInfo: self.scoreTitle, graphType: .WeeklySummarySummaryOfPHQ9)
    }
    
}

class PHQ9ByDate: Codable {
    let date: String
    let score: Int
    let scoreTitle: String?
    
    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(score, forKey: .score)
        try container.encode(scoreTitle, forKey: .scoreTitle)
    }
    
    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(String.self, forKey: .date)
        score = try container.decode(Int.self, forKey: .score)
        scoreTitle = try container.decodeIfPresent(String.self, forKey: .scoreTitle)
    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case date
        case score
        case scoreTitle
    }
}

class SummaryOfPHQ9: Codable {
    let statusResponse: ResponseDetails
    let summaryOfPHQ9: [PHQ9Data]
    let phq9DataByDateRange: [PHQ9ByDate]
    
    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(statusResponse, forKey: .statusResponse)
        try container.encode(summaryOfPHQ9, forKey: .summaryOfPHQ9)
        try container.encode(phq9DataByDateRange, forKey: .phq9DataByDateRange)
    }
    
    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        statusResponse = try container.decode(ResponseDetails.self, forKey: .statusResponse)
        summaryOfPHQ9 = try container.decode([PHQ9Data].self, forKey: .summaryOfPHQ9)
        phq9DataByDateRange = try container.decode([PHQ9ByDate].self, forKey: .phq9DataByDateRange)
    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case statusResponse
        case summaryOfPHQ9
        case phq9DataByDateRange = "PHQ9ByDateRange"
    }
}


//MARK: - Summary Of GAD7
class GAD7WeeklyScore: Codable {
    let date: String
    let score: Int
    let scoreTitle: String?
    
    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(score, forKey: .score)
        try container.encode(scoreTitle, forKey: .scoreTitle)
    }
    
    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(String.self, forKey: .date)
        score = try container.decode(Int.self, forKey: .score)
        scoreTitle = try container.decodeIfPresent(String.self, forKey: .scoreTitle)
    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case date
        case score
        case scoreTitle
    }
    
    
}

class GADDashboard: Codable {
    let screeningId: Int
    let plId: Int
    let score: Int
    let screening: String
    let firstName: String
    let lastName: String
    let scoreTitle: String
    let startDate: String
    let completionDate: String
    let pscreeningId: Int
    
    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(screeningId, forKey: .screeningId)
        try container.encode(plId, forKey: .plId)
        try container.encode(score, forKey: .score)
        try container.encode(screening, forKey: .screening)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(scoreTitle, forKey: .scoreTitle)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(completionDate, forKey: .completionDate)
        try container.encode(pscreeningId, forKey: .pscreeningId)
    }
    
    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        screeningId = try container.decode(Int.self, forKey: .screeningId)
        plId = try container.decode(Int.self, forKey: .plId)
        score = try container.decode(Int.self, forKey: .score)
        screening = try container.decode(String.self, forKey: .screening)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        scoreTitle = try container.decode(String.self, forKey: .scoreTitle)
        startDate = try container.decode(String.self, forKey: .startDate)
        completionDate = try container.decode(String.self, forKey: .completionDate)
        pscreeningId = try container.decode(Int.self, forKey: .pscreeningId)
    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case screeningId
        case plId
        case score
        case screening
        case firstName
        case lastName
        case scoreTitle
        case startDate
        case completionDate
        case pscreeningId
    }
    
    func getGraphData() -> GraphData {
        return GraphData(yAxisValue: self.score, xAxisValue: self.completionDate, additionalInfo: self.scoreTitle, graphType: .WeeklySummarySummaryOfGAD)
    }
}



class SummaryOfGAD7: Codable {
    let weeklyScores: [GAD7WeeklyScore]
    let statusResponse: ResponseDetails
    let gadDashboardByDateRangeList: [GADDashboard]
    
    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(weeklyScores, forKey: .weeklyScores)
        try container.encode(statusResponse, forKey: .statusResponse)
        try container.encode(gadDashboardByDateRangeList, forKey: .gadDashboardByDateRangeList)
    }
    
    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        weeklyScores = try container.decode([GAD7WeeklyScore].self, forKey: .weeklyScores)
        statusResponse = try container.decode(ResponseDetails.self, forKey: .statusResponse)
        gadDashboardByDateRangeList = try container.decode([GADDashboard].self, forKey: .gadDashboardByDateRangeList)
    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case weeklyScores
        case statusResponse
        case gadDashboardByDateRangeList
    }
}

//MARK: - Summary of Audit

class AuditByDateRange: Codable {
    let date: String
    let score: Int
    let scoreTitle: String?
    
    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(score, forKey: .score)
        try container.encode(scoreTitle, forKey: .scoreTitle)
    }
    
    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(String.self, forKey: .date)
        score = try container.decode(Int.self, forKey: .score)
        scoreTitle = try container.decodeIfPresent(String.self, forKey: .scoreTitle)
    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case date
        case score
        case scoreTitle
    }
}

class AuditSummary: Codable {
    let screeningId: Int
    let plId: Int
    let score: Int
    let screening: String
    let firstName: String
    let lastName: String
    let scoreTitle: String
    let startDate: String
    let completionDate: String
    let pscreeningId: Int
    
    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(screeningId, forKey: .screeningId)
        try container.encode(plId, forKey: .plId)
        try container.encode(score, forKey: .score)
        try container.encode(screening, forKey: .screening)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(scoreTitle, forKey: .scoreTitle)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(completionDate, forKey: .completionDate)
        try container.encode(pscreeningId, forKey: .pscreeningId)
    }
    
    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        screeningId = try container.decode(Int.self, forKey: .screeningId)
        plId = try container.decode(Int.self, forKey: .plId)
        score = try container.decode(Int.self, forKey: .score)
        screening = try container.decode(String.self, forKey: .screening)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        scoreTitle = try container.decode(String.self, forKey: .scoreTitle)
        startDate = try container.decode(String.self, forKey: .startDate)
        completionDate = try container.decode(String.self, forKey: .completionDate)
        pscreeningId = try container.decode(Int.self, forKey: .pscreeningId)
    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case screeningId
        case plId
        case score
        case screening
        case firstName
        case lastName
        case scoreTitle
        case startDate
        case completionDate
        case pscreeningId
    }
    
    func getGraphData() -> GraphData {
        return GraphData(yAxisValue: self.score, xAxisValue: self.completionDate, additionalInfo: self.scoreTitle, graphType: .WeeklySummarySummaryOfAudit)
    }
}


class SummaryOfAudit: Codable {
    let statusResponse: ResponseDetails
    let auditByDateRange: [AuditByDateRange]
    let summaryOfAUDIT: [AuditSummary]
    
    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(statusResponse, forKey: .statusResponse)
        try container.encode(auditByDateRange, forKey: .auditByDateRange)
        try container.encode(summaryOfAUDIT, forKey: .summaryOfAUDIT)
    }
    
    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        statusResponse = try container.decode(ResponseDetails.self, forKey: .statusResponse)
        auditByDateRange = try container.decode([AuditByDateRange].self, forKey: .auditByDateRange)
        summaryOfAUDIT = try container.decode([AuditSummary].self, forKey: .summaryOfAUDIT)
    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case statusResponse
        case auditByDateRange
        case summaryOfAUDIT
    }
}


//MARK: - Summary of DAST
class DASTByDateRange: Codable {
    let date: String
    let score: Int
    let scoreTitle: String?
    
    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(score, forKey: .score)
        try container.encode(scoreTitle, forKey: .scoreTitle)
    }
    
    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(String.self, forKey: .date)
        score = try container.decode(Int.self, forKey: .score)
        scoreTitle = try container.decodeIfPresent(String.self, forKey: .scoreTitle)
    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case date
        case score
        case scoreTitle
    }
}

class DASTSummary: Codable {
    let screeningId: Int
    let plId: Int
    let score: Int
    let screening: String
    let firstName: String
    let lastName: String
    let scoreTitle: String
    let startDate: String
    var completionDate: String? = nil
    let pscreeningId: Int
    
    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(screeningId, forKey: .screeningId)
        try container.encode(plId, forKey: .plId)
        try container.encode(score, forKey: .score)
        try container.encode(screening, forKey: .screening)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(scoreTitle, forKey: .scoreTitle)
        try container.encode(startDate, forKey: .startDate)
        try container.encodeIfPresent(completionDate, forKey: .completionDate)
        try container.encode(pscreeningId, forKey: .pscreeningId)
    }
    
    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        screeningId = try container.decode(Int.self, forKey: .screeningId)
        plId = try container.decode(Int.self, forKey: .plId)
        score = try container.decode(Int.self, forKey: .score)
        screening = try container.decode(String.self, forKey: .screening)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        scoreTitle = try container.decode(String.self, forKey: .scoreTitle)
        startDate = try container.decode(String.self, forKey: .startDate)
        completionDate = try container.decodeIfPresent(String.self, forKey: .completionDate)
        pscreeningId = try container.decode(Int.self, forKey: .pscreeningId)
        print(self)
    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case screeningId
        case plId
        case score
        case screening
        case firstName
        case lastName
        case scoreTitle
        case startDate
        case completionDate
        case pscreeningId
    }
    
    func getGraphData() -> GraphData {
        return GraphData(yAxisValue: self.score, xAxisValue: self.startDate, additionalInfo: self.scoreTitle, graphType: .WeeklySummarySummaryOfDast)
    }
}


class SummaryOfDAST: Codable {
    let statusResponse: ResponseDetails
    let summaryOfDAST: [DASTSummary]
    let dateRangeDAST: [DASTByDateRange]
    
    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(statusResponse, forKey: .statusResponse)
        try container.encode(summaryOfDAST, forKey: .summaryOfDAST)
        try container.encode(dateRangeDAST, forKey: .dateRangeDAST)
    }
    
    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        statusResponse = try container.decode(ResponseDetails.self, forKey: .statusResponse)
        summaryOfDAST = try container.decode([DASTSummary].self, forKey: .summaryOfDAST)
        dateRangeDAST = try container.decode([DASTByDateRange].self, forKey: .dateRangeDAST)
    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case statusResponse
        case summaryOfDAST
        case dateRangeDAST = "DASTByDateRange"
    }
}

//MARK: - Journal Entry

class JournalEntry: Codable {
    let plId: Int
    let entry: String
    let createdAt: String
    let sno: Int
    
    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(plId, forKey: .plId)
        try container.encode(entry, forKey: .entry)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(sno, forKey: .sno)
    }
    
    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        plId = try container.decode(Int.self, forKey: .plId)
        entry = try container.decode(String.self, forKey: .entry)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        sno = try container.decode(Int.self, forKey: .sno)
    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case plId
        case entry
        case createdAt
        case sno
    }
}

class JournalResponse: Codable {
    let response: ResponseDetails
    let journalEntriesList: [JournalEntry]
    
    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(response, forKey: .response)
        try container.encode(journalEntriesList, forKey: .journalEntriesList)
    }
    
    // Decoding function
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        response = try container.decode(ResponseDetails.self, forKey: .response)
        journalEntriesList = try container.decode([JournalEntry].self, forKey: .journalEntriesList)
    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case response
        case journalEntriesList
    }
}


//MARK: - EndPoint Request

protocol CodableRequestFormParams {
    func getRequestFormParams(startDate:String,endDate:String) -> [String:Any]
}

extension CodableRequestFormParams {
    func getRequestFormParams(startDate:String,endDate:String) -> [String:Any] {
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        var requestParams:[String:Any] = [:]
        requestParams["patientLocationId"] = userInfo.patientLocationID
        requestParams["fromDate"] = startDate
        requestParams["toDate"] = endDate
        requestParams["patientId"] = userInfo.patientID
      //  requestParams["userId"] = userInfo.userID
        requestParams["clientId"] = userInfo.clientID
        requestParams["userId"] = userInfo.userID
        
        
//        {
//            "patientLocationId": 21,
//            "fromDate": "08/01/2024",
//            "toDate": "08/14/2024",
//            "patientId": 34,
//            "clientId": 1,
//            "userId": 393
//        }
        
//        {
//            "patientLocationId": 4,
//            "fromDate": "05/03/2024",
//            "patientId": 4,
//            "clientId": 1,
//            "entry":""
//        }
        
        return requestParams
    }
}

class GetMoodDataRequestForm : EndPointRequest, CodableRequestFormParams {
    var baseURL: String = baseURLString
    var path: String = "patients/api/v1/patientDetails/getPatientMoodByPatientIdForMobile"
    var httpMethod: HTTPMethod = .post
    var requestBody: [String : Any] = [:]
    
    required init(startDate:String, endDate:String) {
        requestBody = getRequestFormParams(startDate: startDate, endDate: endDate)
    }
}

class GetSleepDataRequestForm : EndPointRequest, CodableRequestFormParams  {
    var baseURL: String = baseURLString
    var path: String = "patients/api/v1/patientDetails/getPatientSleepMonitoringByIdForMobile"
    var httpMethod: HTTPMethod = .post
    var requestBody: [String : Any] = [:]
    
    required init(startDate:String, endDate:String) {
        requestBody = getRequestFormParams(startDate: startDate, endDate: endDate)
    }
}

class GetPHQ9RequestForm : EndPointRequest, CodableRequestFormParams {
    var baseURL: String = baseURLString
    var path: String = "patients/api/v1/patientDetails/getPHQDashboardByDateRange"
    var httpMethod: HTTPMethod = .post
    var requestBody: [String : Any] = [:]
    
    required init(startDate:String, endDate:String) {
        requestBody = getRequestFormParams(startDate: startDate, endDate: endDate)
    }
    
    func getRequestFormParams(startDate:String,endDate:String) -> [String:Any] {
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        var requestParams:[String:Any] = [:]
        requestParams["plId"] = userInfo.patientLocationID
        requestParams["fromDate"] = startDate
        requestParams["toDate"] = endDate
        requestParams["patientId"] = userInfo.patientID
        requestParams["userId"] = userInfo.userID
        requestParams["clientId"] = userInfo.clientID
        
        return requestParams
    }
}

class GetGAD7RequestForm : EndPointRequest, CodableRequestFormParams {
    var baseURL: String = baseURLString
    var path: String = "patients/api/v1/patientDetails/getGADDashboardByDateRange"
    var httpMethod: HTTPMethod = .post
    var requestBody: [String : Any] = [:]
    
    required init(startDate:String, endDate:String) {
        requestBody = getRequestFormParams(startDate: startDate, endDate: endDate)
        print(requestBody)
    }
    
    func getRequestFormParams(startDate:String,endDate:String) -> [String:Any] {
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        var requestParams:[String:Any] = [:]
        requestParams["plId"] = userInfo.patientLocationID
        requestParams["fromDate"] = startDate
        requestParams["toDate"] = endDate
        requestParams["patientId"] = userInfo.patientID
        requestParams["userId"] = userInfo.userID
        requestParams["clientId"] = userInfo.clientID
        
        return requestParams
    }
}

class GetAuditRequestForm : EndPointRequest, CodableRequestFormParams {
    var baseURL: String = baseURLString
    var path: String = "patients/api/v1/patientDetails/getSummaryOfAUDITByDateRange"
    var httpMethod: HTTPMethod = .post
    var requestBody: [String : Any] = [:]
    
    required init(startDate:String, endDate:String) {
        requestBody = getRequestFormParams(startDate: startDate, endDate: endDate)
    }
    
    func getRequestFormParams(startDate:String,endDate:String) -> [String:Any] {
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        var requestParams:[String:Any] = [:]
        requestParams["plId"] = userInfo.patientLocationID
        requestParams["fromDate"] = startDate
        requestParams["toDate"] = endDate
        requestParams["patientId"] = userInfo.patientID
        requestParams["userId"] = userInfo.userID
        requestParams["clientId"] = userInfo.clientID
        
        return requestParams
    }
}

class GetDASTRequestForm : EndPointRequest, CodableRequestFormParams {
    var baseURL: String = baseURLString
    var path: String = "patients/api/v1/patientDetails/getSummaryOfDASTByDateRange"
    var httpMethod: HTTPMethod = .post
    var requestBody: [String : Any] = [:]
    
    required init(startDate:String, endDate:String) {
        requestBody = getRequestFormParams(startDate: startDate, endDate: endDate)
    }
    
    func getRequestFormParams(startDate:String,endDate:String) -> [String:Any] {
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        var requestParams:[String:Any] = [:]
        requestParams["plId"] = userInfo.patientLocationID
        requestParams["fromDate"] = startDate
        requestParams["toDate"] = endDate
        requestParams["patientId"] = userInfo.patientID
        requestParams["userId"] = userInfo.userID
        requestParams["clientId"] = userInfo.clientID
        
        return requestParams
    }
}


class GetJournalEntryRequestForm: EndPointRequest, CodableRequestFormParams {
    var baseURL: String = baseURLString
    var path: String = "patients/api/v1/patientDetails/getPatientJournalByPatientIdForMobile"
    var httpMethod: HTTPMethod = .post
    var requestBody: [String : Any] = [:]
    
    required init(startDate:String, endDate:String) {
        requestBody = getRequestFormParams(startDate: startDate, endDate: endDate)
    }
}

