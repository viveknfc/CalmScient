//
//  DayFeedbackEveningReminderScheduler.swift
//  Calmscient
//
//  Local daily 7:00 PM reminder when evening day-feedback is still pending (logged in + Remember Me).
//  Does not alter DayFeedbackSessionLogic behavior; reads the same UserDefaults keys.
//
//  Vivek
//  20 May 2026
//

import Foundation
import UIKit
import UserNotifications

enum DayFeedbackEveningReminderScheduler {

    /// Single repeating local notification (7:00 PM, `TimeZone.current`).
    static let notificationIdentifier = "day_feedback_evening_reminder"

    private static let reminderHour = 19
    private static let reminderMinute = 0
    /// Same cutoff as `DayFeedbackSessionLogic` overnight branch (read-only; we do not mutate keys here).
    private static let nextDayCutoffMinutes = 2 * 60 + 59

    private static let notificationTitle = "Calmscient"
    private static let bodyLocalizationKey = "Time to track your well-being."

    // MARK: - Public API

    /// Removes the evening reminder request (pending only).
    static func cancelEveningReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
    }

    /// Re-evaluates whether a daily 7 PM reminder should exist. Safe to call from main thread anytime.
    static func refreshSchedulingIfNeeded() {
        DispatchQueue.main.async {
            refreshSchedulingIfNeededOnMain()
        }
    }

    /// Call from notification tap handler when `notificationIdentifier` matches.
    static func handleNotificationResponseIfNeeded(_ response: UNNotificationResponse) {
        guard response.notification.request.identifier == notificationIdentifier else { return }
        openDayFeedbackFromNotificationIfAppropriate()
    }

    // MARK: - Scheduling (main)

    private static func refreshSchedulingIfNeededOnMain() {
        guard isRememberedLoggedInSession() else {
            cancelEveningReminder()
            return
        }

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let allowed: Bool
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                allowed = true
            default:
                allowed = false
            }

            DispatchQueue.main.async {
                guard allowed else {
                    cancelEveningReminder()
                    return
                }

                guard isEveningDayFeedbackStillPending() else {
                    cancelEveningReminder()
                    return
                }

                if isUserOnDayFeedbackScreen() {
                    cancelEveningReminder()
                    return
                }

                scheduleRepeatingSevenPMReminder()
            }
        }
    }

    private static func scheduleRepeatingSevenPMReminder() {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current

        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = TimeZone.current
        components.hour = reminderHour
        components.minute = reminderMinute

        let content = UNMutableNotificationContent()
        content.title = notificationTitle
        content.body = AppHelper.getLocalizeString(str: bodyLocalizationKey)
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("DayFeedbackEveningReminderScheduler: failed to schedule — \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Session / pending evening

    private static func isRememberedLoggedInSession() -> Bool {
        guard UserDefaults.standard.integer(forKey: "rememberMe") == 1 else { return false }
        let (login, token) = UserDefaultsHelper.retrieveLoginDetailsFromUserDefaults()
        return login != nil && token != nil
    }

    /// Evening check-in still needed for the current mood cycle (aligned with `DayFeedbackSessionLogic` saved time + overnight rule).
    private static func isEveningDayFeedbackStillPending(now: Date = Date()) -> Bool {
        guard let saved = effectiveLastSaveDateTime(for: now) else { return true }
        return DayFeedbackSessionLogic.moodDayPeriod(for: saved) != .Evening
    }

    private static func effectiveLastSaveDateTime(for now: Date) -> Date? {
        let calendar = Calendar.current
        guard
            let savedDateString = UserDefaults.standard.string(forKey: DayFeedbackSessionLogic.savedDateUserDefaultsKey),
            let savedTimeString = UserDefaults.standard.string(forKey: DayFeedbackSessionLogic.savedTimeUserDefaultsKey),
            let savedDateTime = combinedSavedDateTime(date: savedDateString, time: savedTimeString)
        else {
            return nil
        }

        let currentComponents = calendar.dateComponents([.hour, .minute], from: now)
        let currentTotalMinutes = (currentComponents.hour ?? 0) * 60 + (currentComponents.minute ?? 0)

        if !calendar.isDate(savedDateTime, inSameDayAs: now), currentTotalMinutes > nextDayCutoffMinutes {
            return nil
        }
        return savedDateTime
    }

    private static func combinedSavedDateTime(date: String, time: String) -> Date? {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: "\(date) \(time)")
    }

    // MARK: - UI visibility

    private static func isUserOnDayFeedbackScreen() -> Bool {
        guard let root = keyWindowRootViewController() else { return false }
        return viewControllerHierarchyContainsDayFeedback(root)
    }

    private static func keyWindowRootViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let window = scenes.first(where: { $0.activationState == .foregroundActive })?.windows.first(where: { $0.isKeyWindow })
            ?? scenes.flatMap(\.windows).first(where: { $0.isKeyWindow })
        return window?.rootViewController
    }

    private static func viewControllerHierarchyContainsDayFeedback(_ vc: UIViewController) -> Bool {
        if vc is DayFeedbackHostingController || vc is UserIntroDayFeedbackViewController {
            return true
        }
        if let nav = vc as? UINavigationController {
            for child in nav.viewControllers where viewControllerHierarchyContainsDayFeedback(child) {
                return true
            }
            if let visible = nav.visibleViewController, viewControllerHierarchyContainsDayFeedback(visible) {
                return true
            }
        }
        if let tab = vc as? UITabBarController, let selected = tab.selectedViewController {
            if viewControllerHierarchyContainsDayFeedback(selected) { return true }
        }
        if let presented = vc.presentedViewController {
            if viewControllerHierarchyContainsDayFeedback(presented) { return true }
        }
        for child in vc.children where viewControllerHierarchyContainsDayFeedback(child) {
            return true
        }
        return false
    }

    // MARK: - Notification tap

    private static func openDayFeedbackFromNotificationIfAppropriate() {
        guard isRememberedLoggedInSession() else { return }
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first(where: { $0.activationState == .foregroundActive })
                    ?? UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first,
                  let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first
            else {
                return
            }
            let homeController = DayFeedbackHostingController()
            let navC = UINavigationController(rootViewController: homeController)
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = navC
            })
        }
    }
}
