//
//  ExcercisesModel.swift
//  CalmscientIOS
//
//  Created by Aishuu on 19/10/24.
//

import UIKit

enum ExcercisesTypeEnum: Int {
    case mindfulness = 1
    case touchAndButterfly
    case handOverHeart
    case mindfulWalking
    case movementDance
    case movementRunning
    case mindfulBodyMovement
    case dummy1 // Movement Dance added for this dummy viv
    case progressive//breathingTechnique
    case breathingTechnique1
    case breathingTechnique2
    case breathingTechnique3
    case breathingTechnique//progressive
    
    var addFavCode: String {
        switch self {
        case .mindfulness:
            return "Mindfulness - what is it?"
        case .progressive:
            return "Progressive muscle relaxation"
        case .touchAndButterfly:
            return "Touch and the butterfly hug"
        case .handOverHeart:
            return "Hand over your heart"
        case .mindfulWalking:
            return "Mindful Walking"
        case .movementDance:
            return "Movement: Dance"
        case .movementRunning:
            return "Movement: Running"
        case .mindfulBodyMovement:
            return "Mindful body movement"
        case .breathingTechnique:
            return "BreathingTechnique" //Breathing technique
        case .breathingTechnique1:
            return "4–7–8 Breathing exercise"
        case .breathingTechnique2:
            return "Mindful breathing exercise"
        case .breathingTechnique3:
            return "Diaphragmatic breathing exercise"
        case .dummy1:
            return "MovementDance"
        }
    }

    /// `Localizable.strings` key for this exercise's title — the same key its own screen
    /// uses, so the Home favorites tile and the screen it opens always read alike.
    ///
    /// Deliberately separate from `addFavCode`: that string is the server contract
    /// ("Movement: Dance", "BreathingTechnique", "4–7–8 Breathing exercise" with en
    /// dashes) and several of its values differ from the localization key by case,
    /// spacing or punctuation. Localizing the server title directly therefore missed the
    /// table and fell back to the key itself, which is why favorites such as
    /// "Movement: Dance" stayed English after a language switch while the exercise page
    /// translated correctly. Changing `addFavCode` instead would break the API payload
    /// and every favorite already stored server-side.
    var localizedTitleKey: String {
        switch self {
        case .mindfulness:          return "Mindfulness - what is it?"
        case .progressive:          return "Progressive muscle relaxation"
        case .touchAndButterfly:    return "Touch and the butterfly hug"
        case .handOverHeart:        return "Hand over your heart"
        case .mindfulWalking:       return "Mindful walking"
        case .movementDance:        return "Movement: dance"
        case .movementRunning:      return "Movement: running"
        case .mindfulBodyMovement:  return "Mindful body movement"
        case .breathingTechnique:   return "Breathing technique"
        case .breathingTechnique1:  return "4-7-8 Breathing excercise"
        case .breathingTechnique2:  return "Mindful breathing exercise"
        case .breathingTechnique3:  return "Diaphragmatic breathing exercise"
        case .dummy1:               return "Movement: dance"   // `destVC` maps this to dance
        }
    }

    /// Resolves the localization key for a title the server sent back, for favorites that
    /// arrive without a usable `screenCode`.
    static func localizedTitleKey(forServerTitle title: String) -> String? {
        let needle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty else { return nil }
        let match = allCases.first {
            $0.addFavCode.compare(needle, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        }
        return match?.localizedTitleKey
    }

    static let allCases: [ExcercisesTypeEnum] = [
        .mindfulness, .touchAndButterfly, .handOverHeart, .mindfulWalking,
        .movementDance, .movementRunning, .mindfulBodyMovement, .dummy1,
        .progressive, .breathingTechnique1, .breathingTechnique2,
        .breathingTechnique3, .breathingTechnique,
    ]
        
        var destVC: UIViewController {
            // Favorites open the SwiftUI exercise screens (parity with the Exercises tab).
            // Deployment target is iOS 16.0, so these hosting controllers are always available.
            if #available(iOS 16.0, *) {
                switch self {
                case .mindfulness:
                    return MindfulnessHostingController()
                case .progressive:
                    return ProgressiveHostingController()
                case .touchAndButterfly:
                    return TouchButterflyIntroHostingController()
                case .handOverHeart:
                    return HandOverYourHeartHostingController()
                case .mindfulWalking:
                    return MindfulWalkingHostingController()
                case .movementDance:
                    return MovementDanceHostingController()
                case .movementRunning:
                    return MovementRunningHostingController()
                case .mindfulBodyMovement:
                    return MindfulBodyMovementHostingController()
                case .breathingTechnique:
                    return BreathingTechniqueHostingController()
                case .breathingTechnique1:
                    return BreathingTechniqueType1HostingController()
                case .breathingTechnique2:
                    return MindfulBreathingHostingController()
                case .breathingTechnique3:
                    return DiaphragmaticBreathingHostingController()
                case .dummy1:
                    return MovementDanceHostingController()
                }
            }
            // Unreachable (min deployment iOS 16.0); required for exhaustive return.
            return UIViewController()
        }
    
}

class ExcercisesModel: Encodable, Decodable {
    let isFav: Int
    let screenCode: Int
    
    init(isFav: Int, screenCode: Int) {
        self.isFav = isFav
        self.screenCode = screenCode
    }
}
