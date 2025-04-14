//
//  TimeZoneHelper.swift
//  CalmscientIOS
//
//  Created by NFC User on 30/01/25.
//

import Foundation

class TimeZoneHelper {
    static func isTimeZoneChanged() -> Bool {
        let calendar = Calendar.current
        let now = Date()

        // Retrieve saved date and time
        if let savedDateString = UserDefaults.standard.string(forKey: "savedDate"),
           let savedTimeString = UserDefaults.standard.string(forKey: "savedTime") {
            
            print("entered here")
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            if let savedDateTime = dateFormatter.date(from: "\(savedDateString) \(savedTimeString)") {
                let savedZone = getDayTime(date: savedDateTime)
                let currentZone = getDayTime(date: now)

                // Define outdated condition (past 2:59 AM the next day)
                let currentComponents = calendar.dateComponents([.hour, .minute], from: now)
                let currentTotalMinutes = (currentComponents.hour ?? 0) * 60 + (currentComponents.minute ?? 0)
                let nextDayEnd = 2 * 60 + 59  // 02:59 AM

                if !calendar.isDate(savedDateTime, inSameDayAs: now) && currentTotalMinutes > nextDayEnd {
                    print("Saved time is outdated. Removing from UserDefaults.")
                    UserDefaults.standard.removeObject(forKey: "savedDate")
                    UserDefaults.standard.removeObject(forKey: "savedTime")
                    return true  // Outdated → return true
                }

                print("the zone bool is from time zone chnage is", savedZone != currentZone)
                return savedZone != currentZone  // Return true if zones are different, false if same
            }
        }

        return true  // No saved time found → Consider it changed
    }
    
    private static func getDayTime(date: Date) -> DayTimeValue {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)

        let totalMinutes = hour * 60 + minute

        switch totalMinutes {
        case (3 * 60)..<(18 * 60): // 3:00 AM to 5:59 PM
            return .Morning
        default: // 6:00 PM to 2:59 AM
            return .Evening
        }
    }
}
