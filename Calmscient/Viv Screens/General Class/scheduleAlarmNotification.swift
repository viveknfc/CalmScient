//
//  scheduleAlarmNotification.swift
//  CalmscientIOS
//
//  Created by NFC User on 08/04/25.
//

import Foundation
import UserNotifications

class AlarmManager {
    static let shared = AlarmManager()

    func scheduleAlarm(at date: Date, title: String, body: String, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.criticalSoundNamed(
            UNNotificationSoundName(rawValue: "bell.mp3")
        )

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                          from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            } else {
                print("Notification scheduled for \(date)")
            }
        }
    }

    func removeAllAppointmentAlarms() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let appointmentRequestIDs = requests
                .map { $0.identifier }
                .filter { $0.hasPrefix("appointment_") }

            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: appointmentRequestIDs)
            print("Removed \(appointmentRequestIDs.count) existing appointment notifications")
        }
    }

    
}


