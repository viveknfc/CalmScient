//
//  ExerciseAudioSilentModeGuard.swift
//  Calmscient
//
//  Determines whether exercise audio playback should be blocked in silent mode.
//
//  Vivek
//  26 May 2026
//

import AVFoundation
import UIKit

enum ExerciseAudioSilentModeGuard {
    static func shouldBlockPlayback() -> Bool {
        let session = AVAudioSession.sharedInstance()
        return session.secondaryAudioShouldBeSilencedHint || session.outputVolume <= 0.001
    }

    static func showSilentModeToast(on view: UIView?) {
        view?.showToast(message: ProgressivePresentation.silentModeToastKey.localized)
    }
}
