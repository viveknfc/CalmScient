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
    
    var storyboardID: String {
        switch self {
        case .mindfulness:
            return "MindfulNess"
        case .progressive:
            return "Progressive"
        case .touchAndButterfly:
            return "TouchAndButterFly2"
        case .handOverHeart:
            return "HandOverYourHeart"
        case .mindfulWalking:
            return "MindfulWalking"
        case .movementDance:
            return "MovementDance"
        case .movementRunning:
            return "MovementRunning"
        case .mindfulBodyMovement:
            return "MindfulBodyMovement"
        case .breathingTechnique:
            return "BreathingTechnique"
        case .breathingTechnique1:
            return "BreathingTechniqueType1"
        case .breathingTechnique2:
            return "MindfulBreathing"
        case .breathingTechnique3:
            return "DiagraphicBreathe"
        case .dummy1:
            return "MovementDance"
        }
    }
    
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
        
        var destVC: UIViewController {
            let storyboard = UIStoryboard(name: "Excercises", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: self.storyboardID);
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
