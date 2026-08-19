//
//  ExercisesRoute.swift
//  Calmscient
//
//  Destinations for the SwiftUI Exercises tab `NavigationStack`.
//
//  The exercise screens are reachable two ways:
//    1. the Exercises tab — SwiftUI `NavigationStack`, driven by these routes
//    2. Home ▸ favourites — still UIKit, via `ExcercisesTypeEnum.destVC`
//  So every view model keeps its UIKit push/pop as the fallback and only uses the
//  route closures when they are set (i.e. when shown from the tab).
//

import Foundation

enum ExercisesRoute: Hashable {
    case mindfulness
    case progressive
    case touchButterflyIntro
    case touchButterflyHowTo
    case handOverYourHeart
    case mindfulWalking
    case movementDance
    case movementRunning
    case mindfulBodyMovement
    case breathingTechnique
    case breathingType1
    case mindfulBreathing
    case diaphragmaticBreathing
}

// MARK: - Mapping from the favourites screen code

extension ExercisesRoute {
    /// Mirrors `ExcercisesTypeEnum.destVC` so a Home favourite opens the same screen
    /// whether it routes natively or through the legacy hosting controller.
    init(exercise: ExcercisesTypeEnum) {
        switch exercise {
        case .mindfulness:         self = .mindfulness
        case .touchAndButterfly:   self = .touchButterflyIntro
        case .handOverHeart:       self = .handOverYourHeart
        case .mindfulWalking:      self = .mindfulWalking
        case .movementDance:       self = .movementDance
        case .movementRunning:     self = .movementRunning
        case .mindfulBodyMovement: self = .mindfulBodyMovement
        case .dummy1:              self = .movementDance   // parity: destVC maps this to dance
        case .progressive:         self = .progressive
        case .breathingTechnique1: self = .breathingType1
        case .breathingTechnique2: self = .mindfulBreathing
        case .breathingTechnique3: self = .diaphragmaticBreathing
        case .breathingTechnique:  self = .breathingTechnique
        }
    }
}


// MARK: - Chrome for the Home tab's bridge

extension ExercisesRoute {

    /// Navigation title for the screen behind this route.
    ///
    /// The Home tab reaches these screens by bridging to their UIKit hosting controllers
    /// (favourites on the dashboard). That controller's `navigationItem` belongs to a
    /// child of the `NavigationStack`'s controller, so the title and back button it
    /// installs never reach the visible bar — the screen opens with a blank one. These
    /// mirror each view model's `screenTitle`; the Exercises tab reads them from the view
    /// model directly and does not use this.
    var screenTitle: String {
        switch self {
        case .mindfulness:            return "Mindfulness - what is it?".localized
        case .progressive:            return ProgressivePresentation.screenTitleKey.localized
        case .touchButterflyIntro,
             .touchButterflyHowTo:    return TouchButterflyHugPresentation.screenTitleKey.localized
        case .handOverYourHeart:      return HandOverYourHeartPresentation.screenTitleKey.localized
        case .mindfulWalking:         return MindfulWalkingPresentation.screenTitleKey.localized
        case .movementDance:          return MovementDancePresentation.screenTitleKey.localized
        case .movementRunning:        return MovementRunningPresentation.screenTitleKey.localized
        case .mindfulBodyMovement:    return MindfulBodyMovementPresentation.screenTitleKey.localized
        case .breathingTechnique:     return "Breathing technique".localized
        case .breathingType1:         return "4-7-8 Breathing excercise".localized
        case .mindfulBreathing:       return "Mindful breathing exercise".localized
        case .diaphragmaticBreathing: return "Diaphragmatic breathing exercise".localized
        }
    }
}
