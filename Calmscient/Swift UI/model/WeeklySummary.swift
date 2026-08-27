//
//  WeeklySummary.swift
//  CalmscientIOS
//
//  Created by NFC on 28/04/24.
//

import Foundation


public enum WeeklySummaryGraphViewTableCell {
    case GraphSelectionTableHeaderCell
    case WeeklySummaryGraphViewCell
    case WeeklySummaryBarChartViewCell
    case WeeklySummarySleepAverageViewCell
    
    func getCellIdentifier() -> String {
        switch self {
        case .GraphSelectionTableHeaderCell:
            return "ChartViewHeaderTableCell"
        case .WeeklySummarySleepAverageViewCell:
            return "SleepSummaryTableViewCell"
        default:
            return "ChartViewTableCell"
        }
    }
    
    
    func getCellHeight() -> CGFloat {
        switch self {
        case .GraphSelectionTableHeaderCell:
            return 60
        case .WeeklySummarySleepAverageViewCell:
            return 300
        default:
            return 330
        }
    }
}

public enum WeeklySummaryItems:String {
    case WeeklySummarySummaryOfMood = "Summary Of Mood"
    case WeeklySummarySummaryOfSleep = "Summary of sleep"
    case WeeklySummarySummaryOfPHQ9 = "Summary Of PHQ9"
    case WeeklySummarySummaryOfGAD = "Summary Of GAD"
    case WeeklySummarySummaryOfAudit = "Summary Of Audit"
    case WeeklySummarySummaryOfDast = "Summary Of Dast"
    case WeeklySummaryProgressOnCourseWork = "Progress On Course Work"
    case WeeklySummaryJournalEntry = "Journal Entry"
    case WeeklySummaryCAGE = "Summary of CAGE"
    
    var localized: String {
          switch self {
          case .WeeklySummarySummaryOfMood:
              return "Summary of mood".localized
          case .WeeklySummarySummaryOfSleep:
              return "Summary of sleep".localized
          case .WeeklySummarySummaryOfPHQ9:
              return "Summary of PHQ-9".localized;
          case .WeeklySummarySummaryOfGAD:
              return "Summary of GAD-7".localized;
          case .WeeklySummarySummaryOfAudit:
              return "Summary of AUDIT".localized
          case .WeeklySummarySummaryOfDast:
              return "Summary of DAST-10".localized
          case .WeeklySummaryProgressOnCourseWork:
              return "Progress on course work".localized
          case .WeeklySummaryJournalEntry:
              return "Journal entry".localized
          case .WeeklySummaryCAGE:
              return "Summary of CAGE".localized
          }
      }
    
    var graphTitle: String {
          switch self {
          case .WeeklySummarySummaryOfMood:
              return AppHelper.getLocalizeString(str: "Mood_by_date_range")
          case .WeeklySummarySummaryOfSleep:
              return AppHelper.getLocalizeString(str: "Sleep_by_date_range")
          case .WeeklySummarySummaryOfPHQ9:
              return AppHelper.getLocalizeString(str: "PHQ-9_by_date_range")
          case .WeeklySummarySummaryOfGAD:
              return AppHelper.getLocalizeString(str: "GAD_by_date_range")
          case .WeeklySummarySummaryOfAudit:
              return AppHelper.getLocalizeString(str: "Audit_by_date_range")
          case .WeeklySummarySummaryOfDast:
              return AppHelper.getLocalizeString(str: "Dast_by_date_range")
          case .WeeklySummaryProgressOnCourseWork:
              return ""
          case .WeeklySummaryJournalEntry:
              return ""
          case .WeeklySummaryCAGE:
              return AppHelper.getLocalizeString(str: "CAGE_by_date_range")
          }
      }
    
    public func getAssetName() -> String {
        switch self {
        case .WeeklySummaryJournalEntry:
            return "JournalEntry"
        case .WeeklySummarySummaryOfMood:
            return "SummaryOfMood"
        case .WeeklySummarySummaryOfSleep:
            return "SummaryOfSleep"
        case .WeeklySummarySummaryOfPHQ9:
            return "SummaryOfPHQ9"
        case .WeeklySummarySummaryOfGAD:
            return "SummaryOfGAD"
        case .WeeklySummarySummaryOfAudit:
            return "SummaryOfAudit"
        case .WeeklySummarySummaryOfDast:
            return "SummaryOfDAST"
        case .WeeklySummaryProgressOnCourseWork:
            return "ProgressOnCourseWork"
        case .WeeklySummaryCAGE:
            return "ProgressOnCourseWork"//"CAGE"
        }
    }
    
    func getTableCellList() -> [WeeklySummaryGraphViewTableCell] {
        switch self {
        case .WeeklySummarySummaryOfMood:
            return [.GraphSelectionTableHeaderCell,.WeeklySummaryGraphViewCell, .WeeklySummaryBarChartViewCell]
        case .WeeklySummarySummaryOfSleep:
            return [.GraphSelectionTableHeaderCell,.WeeklySummaryGraphViewCell, .WeeklySummarySleepAverageViewCell]
        default:
            return [.GraphSelectionTableHeaderCell,.WeeklySummaryGraphViewCell]
        }
    }
    
    func getAPIRequestForWeeklySummary(with StartDate:String, endDate:String) -> EndPointRequest {
        switch self {
        case .WeeklySummaryJournalEntry:
            return GetJournalEntryRequestForm(startDate: StartDate, endDate: endDate)
        case .WeeklySummarySummaryOfMood:
            return GetMoodDataRequestForm(startDate: StartDate, endDate: endDate)
        case .WeeklySummarySummaryOfSleep:
            return GetSleepDataRequestForm(startDate: StartDate, endDate: endDate)
        case .WeeklySummarySummaryOfPHQ9:
            return GetPHQ9RequestForm(startDate: StartDate, endDate: endDate)
        case .WeeklySummarySummaryOfGAD:
            return GetGAD7RequestForm(startDate: StartDate, endDate: endDate)
        case .WeeklySummarySummaryOfAudit:
            return GetAuditRequestForm(startDate: StartDate, endDate: endDate)
        case .WeeklySummarySummaryOfDast:
            return GetDASTRequestForm(startDate: StartDate, endDate: endDate)
        case .WeeklySummaryProgressOnCourseWork:
            fatalError("WeeklySummaryItems Wrongly API called")
        case .WeeklySummaryCAGE:
            return GetCAGERequestForm(startDate: StartDate, endDate: endDate)
        }
    }
    
    func getGraphDataForWeeklySummary(responseData:Data?) -> ([GraphData], ResponseDetails?) {
        let decoder = JSONDecoder()
        switch self {
        case .WeeklySummarySummaryOfMood:
            guard let responseDecoded = try? decoder.decode(SummaryOfMood.self, from: responseData!) else {
                return ([],nil)
             }
            let results = responseDecoded.moodMonitorList.map { obj in
                return obj.getGraphData()
            }
            return (results,responseDecoded.response)
        case .WeeklySummarySummaryOfSleep:
            guard let responseDecoded = try? decoder.decode(SummaryOfSleep.self, from: responseData!) else {
                return ([],nil)
             }
            let results = responseDecoded.sleepMonitorList.map { obj in
                return obj.getGraphData()
            }
            return (results,responseDecoded.statusResponse)
        case .WeeklySummarySummaryOfPHQ9:
            guard let responseDecoded = try? decoder.decode(SummaryOfPHQ9.self, from: responseData!) else {
                return ([],nil)
             }
            let results = responseDecoded.summaryOfPHQ9.map { obj in
                return obj.getGraphData()
            }
            return (results,responseDecoded.statusResponse)
        case .WeeklySummarySummaryOfGAD:
            guard let responseDecoded = try? decoder.decode(SummaryOfGAD7.self, from: responseData!) else {
                return ([],nil)
             }
            let results = responseDecoded.gadDashboardByDateRangeList.map { obj in
                return obj.getGraphData()
            }
            return (results,responseDecoded.statusResponse)
        case .WeeklySummarySummaryOfAudit:
            guard let responseDecoded = try? decoder.decode(SummaryOfAudit.self, from: responseData!) else {
                return ([],nil)
             }
            let results = responseDecoded.summaryOfAUDIT.map { obj in
                return obj.getGraphData()
            }
            return (results,responseDecoded.statusResponse)
        case .WeeklySummarySummaryOfDast:
            guard let responseDecoded = try? decoder.decode(SummaryOfDAST.self, from: responseData!) else {
                return ([],nil)
             }
            let results = responseDecoded.summaryOfDAST.map { obj in
                return obj.getGraphData()
            }
            return (results,responseDecoded.statusResponse)
        case .WeeklySummaryCAGE:
            guard let responseDecoded = try? decoder.decode(SummaryOfCAGE.self, from: responseData!) else {
                return ([],nil)
             }
            let results = responseDecoded.summaryofCAGEAID.map { obj in
                return obj.getGraphData()
            }
            return (results,responseDecoded.statusResponse)
        default:
            fatalError("WeeklySummaryItems Unknown Data Handling")
        }
    }
    
    func getServerResponsefrom(startDate:String, and endDate:String,completion:@escaping((_ graphData:[GraphData]?, _ serverResponse:ResponseDetails?, _ error:Error?) -> Void)) {
        
        guard NetworkMonitor.shared.isConnected else {
            DispatchQueue.main.async {
                NoInternetBanner.shared.show()
            }
            return
        }
        
        let weekySummaryRequestForm = self.getAPIRequestForWeeklySummary(with: startDate, endDate: endDate)
        guard let apiRequest = weekySummaryRequestForm.getURLRequest() else {
            return
        }
        
        NetworkLogger.log(request: apiRequest)

        // Console-only trace. This request is built from `EndPointRequest` directly
        // rather than through `APIService`, so it needs its own log line.
        APILogger.logRequest(
            apiRequest,
            params: weekySummaryRequestForm.requestBody,
            placement: "body",
            label: "weeklySummary"
        )

        let task = URLSession.shared.dataTask(with: apiRequest) { data, response, error in
            NetworkLogger.log(response: data)
            
            if let responseError = error {
                DispatchQueue.main.async {
                    completion(nil, nil, responseError)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil,nil,DefaultError())
                }
                return
            }
            
            let result = self.getGraphDataForWeeklySummary(responseData: data)
            DispatchQueue.main.async {
                completion(result.0,result.1,nil)
            }
        }
        task.resume()
    }
    
}
