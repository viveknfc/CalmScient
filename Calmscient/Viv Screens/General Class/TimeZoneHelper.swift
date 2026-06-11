//
//  TimeZoneHelper.swift
//  CalmscientIOS
//
//  Created by NFC User on 30/01/25.
//
//  Foreground day-feedback re-prompt logic lives in `DayFeedbackSessionLogic`.
//

import Foundation

class TimeZoneHelper {

    static func isTimeZoneChanged() -> Bool {
        DayFeedbackSessionLogic.shouldPromptDayFeedbackOnForeground()
    }
}
