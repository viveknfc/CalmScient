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

    /// The bundled artwork the Exercises grid shows for this exercise.
    ///
    /// `ExerciseFavoriteToggle` saves a favorite with only `isFav`, `pageId`, `patientId`
    /// and `title` — it never sends a thumbnail — so whether the favorites payload comes
    /// back carrying a `thumbnailUrl` depends entirely on the backend resolving that row
    /// to a content record. For the exercises it cannot resolve, the Home tile had nothing
    /// to draw. The app already ships the art (`ExcercisesAssets.xcassets`), so the tile
    /// falls back to the very same image the Exercises tab uses.
    ///
    /// Names match `ExercisesViewModel.buildCards()` exactly. The three breathing
    /// exercises sit under the single "Breathing technique" card in the grid, so they
    /// share its artwork; `dummy1` shares dance's, matching `destVC`.
    var favoriteThumbnailAssetName: String {
        switch self {
        case .mindfulness:          return "mindfulness"
        case .progressive:          return "progressiveWithHeadset"
        case .touchAndButterfly:    return "touchAndButterfly"
        case .handOverHeart:        return "handover"
        case .mindfulWalking:       return "mindfulWalking_index"
        case .movementDance:        return "movement"
        case .movementRunning:      return "movementRunning"
        case .mindfulBodyMovement:  return "MindFulBodyMovement"
        case .breathingTechnique:   return "breathingTechnique"
        case .breathingTechnique1:  return "breathingTechnique"
        case .breathingTechnique2:  return "breathingTechnique"
        case .breathingTechnique3:  return "breathingTechnique"
        case .dummy1:               return "movement"
        }
    }

    /// Resolves the localization key for a title the server sent back, for favorites that
    /// arrive without a usable `screenCode`.
    static func localizedTitleKey(forServerTitle title: String) -> String? {
        matching(serverTitle: title)?.localizedTitleKey
    }

    /// The exercise whose `addFavCode` the server echoed back as this favorite's title.
    ///
    /// Split out of `localizedTitleKey(forServerTitle:)` so the title and the artwork are
    /// resolved by one identical comparison — `addFavCode` differs from the localization
    /// key by case, spacing and punctuation, and matching it two different ways is exactly
    /// how those two drift apart.
    static func matching(serverTitle title: String) -> ExcercisesTypeEnum? {
        let needle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty else { return nil }
        return allCases.first {
            $0.addFavCode.compare(needle, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        }
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
