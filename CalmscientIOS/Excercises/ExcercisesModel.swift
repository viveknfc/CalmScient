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
    case breathingTechnique
    case progressive
    
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
            return "Breathing technique"
        }
    }
    
//    var viewController: UIViewController {
        
        var destVC: UIViewController {
            let storyboard = UIStoryboard(name: "Excercises", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: self.storyboardID);
//            switch self {
//            case .mindfulness:
//                
//            default:
//                return MindfulNess()
//                //        case .progressive:
//                //            return ""
//                //        case .touchAndButterfly:
//                //            return ""
//                //        case .handOverHeart:
//                //            return ""
//                //        case .mindfulWalking:
//                //            return ""
//                //        case .movementDance:
//                //            return ""
//                //        case .movementRunning:
//                //            return ""
//                //        case .mindfulBodyMovement:
//                //            return ""
//                //        case .breathingTechnique:
//                //            return ""
//            }
        }
//    }
    
}

class ExcercisesModel: Encodable, Decodable {
    let isFav: Int
    let screenCode: Int
    
    init(isFav: Int, screenCode: Int) {
        self.isFav = isFav
        self.screenCode = screenCode
    }
}
