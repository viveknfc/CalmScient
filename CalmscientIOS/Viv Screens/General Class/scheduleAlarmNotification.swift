//
//  scheduleAlarmNotification.swift
//  CalmscientIOS
//
//  Created by NFC User on 08/04/25.
//

import Foundation
import UserNotifications

func scheduleAlarmNotification(
    dateTimeString: String,
    dateFormat: String,
    alarmOffset: TimeInterval,
    title: String,
    body: String
) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    dateFormatter.timeZone = TimeZone.current

    guard let scheduledDate = dateFormatter.date(from: dateTimeString) else {
        print("Invalid datetime string passed:", dateTimeString)
        return
    }

    let alarmDate = scheduledDate.addingTimeInterval(-alarmOffset)

    if alarmDate <= Date() {
        print("Alarm time is in the past. Not scheduling.")
        return
    }

    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default
    
    if #available(iOS 15.0, *) {
        content.interruptionLevel = .critical
    } else {
        // Fallback on earlier versions
    }
    
    content.sound = UNNotificationSound.criticalSoundNamed(
        UNNotificationSoundName(rawValue: "bell.mp3")
    )

    let triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: alarmDate)

    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)

    let request = UNNotificationRequest(
        identifier: UUID().uuidString,
        content: content,
        trigger: trigger
    )

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Failed to schedule notification:", error)
        } else {
            print("Notification scheduled at:", alarmDate)
        }
    }
}

