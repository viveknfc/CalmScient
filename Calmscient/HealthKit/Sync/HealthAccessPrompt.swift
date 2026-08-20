//
//  HealthAccessPrompt.swift
//  Calmscient
//
//  Created by NFC Solutions on 19/08/26.
//

import Foundation
import UIKit
import HealthKit

/// Asks for HealthKit access from the dashboard.
///
/// Until now the only place that asked was the Health Metrics screen. That is good in-context
/// design for a screen the user chose to open — but background sync exists for the patients who
/// *never* open it, and those were exactly the ones never being asked.
///
/// It is a short alert of our own rather than Apple's sheet straight away, for one reason:
/// tapping "Not now" here records nothing with iOS, so the sheet can still be shown later.
/// "Don't Allow" on Apple's sheet is permanent for those types and only reversible through
/// Settings, which almost nobody finds. The alert keeps people away from the irreversible no
/// until they know why they are being asked.
///
/// The Health Metrics request stays exactly as it is and becomes the recovery path: someone who
/// taps "Not now" here is asked again the moment they open that screen.
enum HealthAccessPrompt {

    /// Set when the user taps "Not now", so the dashboard asks once and does not nag.
    private static let declinedDefaultsKey = "HealthSync.dashboardPromptDeclined"

    /// `onHostWillAppear` fires every time the dashboard comes back into view — returning from a
    /// pushed screen, switching tabs, a language change — not just on first load. Without this
    /// the alert would reappear constantly while a decision is pending.
    private static var hasShownThisLaunch = false

    static func presentIfNeeded(from host: UIViewController?) {
        guard let host = host else { return }
        guard !hasShownThisLaunch else { return }

        // False on iPad and anywhere else without Health.
        guard HKHealthStore.isHealthDataAvailable() else { return }

        guard !UserDefaults.standard.bool(forKey: declinedDefaultsKey) else { return }

        // No session means no upload to authorise, so there is nothing to ask for yet.
        guard HealthSyncCredentials.forForegroundSync() != nil else { return }

        hasShownThisLaunch = true

        Task {
            // Ask iOS whether showing anything would achieve something. `.shouldRequest` means at
            // least one requested type has never been answered; anyone who already granted — or
            // already refused — is skipped silently. This is also what makes a newly added read
            // type (the workout permission) reach existing users without a second mechanism.
            guard await HealthKitManager.shared.needsAuthorizationRequest() else { return }

            await MainActor.run {
                afterTransition(on: host) { showAlert(from: host) }
            }
        }
    }

    // MARK: - Presentation

    /// Waits out any in-flight navigation before presenting.
    ///
    /// Mirrors the guard already used in `HealthMetricsViewModel.requestAccessAndLoad()`. The
    /// dashboard calls this from `viewWillAppear`, so a tab switch or a pop can still be animating;
    /// putting a modal up in the middle of that is what produces the visible jump.
    private static func afterTransition(on host: UIViewController, _ work: @escaping () -> Void) {
        guard let coordinator = host.transitionCoordinator else {
            work()
            return
        }
        let scheduled = coordinator.animate(alongsideTransition: nil) { _ in work() }

        // The coordinator refuses blocks for a non-animatable transition; without this fallback
        // the prompt would never appear.
        if !scheduled { work() }
    }

    private static func showAlert(from host: UIViewController) {
        // Never stack on whatever the dashboard may already be showing — the token-refresh
        // spinner, a no-internet banner. Presenting over an in-flight modal is the other way to
        // get a flick.
        guard host.presentedViewController == nil else { return }

        let message = "Calmscient can read your heart rate, activity and sleep so your care team can see how you're doing between visits.".localized
            + "\n\n"
            + "On the next screen, tap Turn All Categories On.".localized

        let alert = UIAlertController(title: "Share your health data?".localized,
                                      message: message,
                                      preferredStyle: .alert)

        // "Not now" rather than "Cancel": nothing is being aborted, and the wording should make
        // clear the door stays open.
        alert.addAction(UIAlertAction(title: "Not now".localized, style: .cancel) { _ in
            UserDefaults.standard.set(true, forKey: declinedDefaultsKey)
        })

        alert.addAction(UIAlertAction(title: "Connect".localized, style: .default) { _ in
            // The alert's own dismissal is still settling when this fires. Asking HealthKit to
            // raise its sheet mid-dismissal is the same flick the transition guard above avoids,
            // so the request waits for the next run loop pass.
            DispatchQueue.main.async { requestAccess(from: host) }
        })

        host.present(alert, animated: true)
    }

    // MARK: - Request

    private static func requestAccess(from host: UIViewController) {
        Task {
            do {
                try await HealthKitManager.shared.requestAuthorization()

                // Access has only just become possible, so this is the first moment
                // `enableBackgroundDelivery` can succeed. Arming at launch happened before the
                // user had granted anything.
                HealthSyncCoordinator.shared.restartBackgroundTriggers()

                // Send a first real row straight away rather than waiting for the next slot.
                // Note this succeeds even if the user granted nothing — `requestAuthorization`
                // does not report refusal — but the upload simply carries empty values, which is
                // the honest representation of "no data available".
                HealthSyncCoordinator.shared.syncNow(trigger: .foreground)
            } catch {
                await MainActor.run {
                    host.view.showToast(message: error.localizedDescription)
                }
            }
        }
    }
}
