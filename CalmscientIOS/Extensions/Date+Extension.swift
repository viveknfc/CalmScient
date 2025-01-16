//
//  Date+Extension.swift
//  CalmscientIOS
//
//  Created by NFC on NA.
//

import Foundation

extension Date {
    
    func getStartAndEndOfWeek() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: -weekday + 1, to: today)!
        let endOfWeek = calendar.date(byAdding: .day, value: 7 - weekday, to: today)!
        
        return (startOfWeek, endOfWeek)
    }
    
    
    func isBetween(startDate: Date, endDate: Date) -> Bool {
        return (self >= startDate) && (self <= endDate)
    }
    
    
    func getTomorrowDate() -> Date {
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        return tomorrow
    }
    
    func getStartAndEndOfWeekInString() -> (start: String, end: String) {
        let (startOfWeek,endOfWeek) = getStartAndEndOfWeek()
        return (startOfWeek.dateInMMDDYYYYFormat(), endOfWeek.dateInMMDDYYYYFormat())
    }
 
    func dateInMMDDYYYYFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateFormatter.timeZone = TimeZone(identifier: Calendar.current.timeZone.identifier)
        return dateFormatter.string(from: self)
    }
    
    func dateToString(format:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(identifier: Calendar.current.timeZone.identifier)
        return dateFormatter.string(from: self)
    }
    
    func currentWeekDayShortForm() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE" // EE gives the full name of the day (e.g., "Mon")
        let currentDay = dateFormatter.string(from: currentDate)
        return currentDay
    }
    
        func getOlderDateWithDaysDifference(minusDays: Int) -> Date {
                return Calendar.current.date(byAdding: .day, value: minusDays, to: self) ?? self
            }

    
    func getFromDateAndToDate(minusDays:Int) -> (fromDate:String, toDate:String) {
        var fromDate:Date
        var toDate:Date
        
        if minusDays <= 0 {
            fromDate = getOlderDateWithDaysDifference(minusDays: minusDays)
            toDate = self
        } else {
            fromDate = self
            toDate = getOlderDateWithDaysDifference(minusDays: minusDays)
        }
        return (fromDate.dateToString(format: "MM/dd/yyyy"), toDate.dateToString(format: "MM/dd/yyyy"))
    }
    func getFromDate(minusDays: Int) -> String {
        let fromDate: Date
        
        if minusDays <= 0 {
            fromDate = getOlderDateWithDaysDifference(minusDays: minusDays)
        } else {
            fromDate = self
        }
        
        return fromDate.dateToString(format: "MM/dd/yyyy")
    }
    func datesOfCurrentWeek() -> [Date]? {
        let calendar = Calendar.current
        let currentDate = self
        
        guard let startOfWeek = calendar.startOfWeek(for: currentDate) else {
            return nil
        }
        
        var dates: [Date] = []
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                dates.append(date)
            }
        }
        
        return dates
    }
}


extension Calendar {
    func startOfWeek(for date: Date) -> Date? {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components)
    }
}

