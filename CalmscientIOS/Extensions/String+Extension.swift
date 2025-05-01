//
//  String+Extension.swift
//  CalmscientIOS
//
//  Created by NFC on NA.
//

import Foundation
import UIKit

public enum DayTimeValue:String, Comparable, Equatable {
    public static func < (lhs: DayTimeValue, rhs: DayTimeValue) -> Bool {
        return lhs.getOrder() < rhs.getOrder()
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.getOrder() == rhs.getOrder()
    }

    case Morning = "Morning"
    case Afternoon = "Afternoon"
    case Evening = "Evening"
    
    
    func getIconImage() -> UIImage? {
        switch self {
        case .Morning: return UIImage(named: "Isolation_Mode")
        case .Afternoon:  return UIImage(named: "afternoonSun")
        case .Evening: return UIImage(named: "moon")
//        case .spanishMorning: return UIImage(named: "Isolation_Mode")
//        case .spanishAfternoon:  return UIImage(named: "afternoonSun")
//        case .spanishEvening: return UIImage(named: "moon")
        }
    }
    
    private func getOrder() -> Int {
        switch self {
        case .Morning: return 1
        case .Afternoon:  return 2
        case .Evening: return 3
//        case .spanishMorning: return 1
//        case .spanishAfternoon: return 2
//        case .spanishEvening: return 3
        }
    }
}

extension String {
    
    func toFormattedDateString(inputFormat: String = "yyyy-MM-dd HH:mm:ss", outputFormat: String = "MM/dd/yyyy") -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = inputFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.current
        
        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = outputFormat
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    //Format "YYYY-MM-DD"
    public func dateWithYYYYMMDDHighfenFormat() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD"
        dateFormatter.timeZone = TimeZone(identifier: Calendar.current.timeZone.identifier)
        return dateFormatter.date(from: self)!
    }
    
    func createDateFromTimeString(with formatter: String = "HH:mm:ss") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
        dateFormatter.timeZone = Calendar.current.timeZone
        guard let timeDate = dateFormatter.date(from: self) else {
            return Date()
        }
        
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute, .second, .timeZone], from: timeDate)
        
        let today = Date()
        var todayComponents = calendar.dateComponents([.year, .month, .day, .timeZone], from: today)
        
        todayComponents.hour = timeComponents.hour
        todayComponents.minute = timeComponents.minute
        todayComponents.second = timeComponents.second
        
        return calendar.date(from: todayComponents) ?? Date()
    }

    
    func getDate(formatString:String = "yyyy-MM-dd HH:mm:ss") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatString
        dateFormatter.timeZone = TimeZone(identifier: Calendar.current.timeZone.identifier)
        return dateFormatter.date(from: self) ?? Date()
    }
    
    func isDayTimeAM(formatter:String = "HH:mm:ss") -> Bool { //yyyy-MM-dd
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
        dateFormatter.timeZone = TimeZone(identifier: Calendar.current.timeZone.identifier)

        if let date = dateFormatter.date(from: self) {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            switch hour {
            case 0..<12:
                return true
            default:
                return false
            }
        }
        return false
    }
    
    func isDayTimePM(formatter:String = "HH:mm:ss") -> Bool { //yyyy-MM-dd
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
        dateFormatter.timeZone = TimeZone(identifier: Calendar.current.timeZone.identifier)

        if let date = dateFormatter.date(from: self) {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            switch hour {
            case 12..<18:
                return true
            default:
                return false
            }
        }
        return false
    }
    
    func isDayTimeEvening(formatter: String = "HH:mm:ss") -> Bool { //yyyy-MM-dd 
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
        dateFormatter.timeZone = TimeZone(identifier: Calendar.current.timeZone.identifier)

        if let date = dateFormatter.date(from: self) {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            switch hour {
            case 18..<24:
                return true
            default:
                return false
            }
        }
        return false
    }

    
    func getDayTimeFromDate(formatter: String = "yyyy-MM-dd HH:mm:ss", includeTimeZone: Bool = false) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
//        dateFormatter.timeZone = TimeZone(identifier: Calendar.current.timeZone.identifier)
        
        if let date = dateFormatter.date(from: self) {
            let calendar = Calendar.current
            var hour = calendar.component(.hour, from: date)
            let minute = calendar.component(.minute, from: date)

            switch hour {
            case 0..<12:
                if includeTimeZone {
                    let formattedHour = String(format: "%02d", hour)
                    let formattedMinute = String(format: "%02d", minute)
                    let ampm = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "AM" : "AM" //a. m.
                    return "\(formattedHour):\(formattedMinute) \(ampm)"
                } else {
                    return DayTimeValue.Morning.rawValue 
                }
            case 12..<18:
                if includeTimeZone {
                    if hour > 12 {
                        hour = hour % 12
                    }
                    let formattedHour = String(format: "%02d", hour)
                    let formattedMinute = String(format: "%02d", minute)
                    let ampm = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "PM" : "PM" //p. m.
                    return "\(formattedHour):\(formattedMinute) \(ampm)"
                } else {
                    return DayTimeValue.Afternoon.rawValue
                }
            default:
                if includeTimeZone {
                    if hour > 12 {
                        hour = hour % 12
                    }
                    let formattedHour = String(format: "%02d", hour)
                    let formattedMinute = String(format: "%02d", minute)
                    let ampm = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "PM" : "PM" //p. m.
                    return "\(formattedHour):\(formattedMinute) \(ampm)"
                } else {
                    return DayTimeValue.Evening.rawValue
                }
            }
        } else {
            return nil
        }
    }

    
    
    
}


