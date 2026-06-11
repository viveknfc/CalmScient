//
//  ExercisesCardItem.swift
//  Calmscient
//
//  Model for Exercises grid cards.
//
//  Vivek
//  26 May 2026
//

import Foundation

@available(iOS 16.0, *)
struct ExercisesCardItem: Identifiable, Hashable {
    enum Destination: Hashable {
        case mindfulness
        case progressiveMuscleRelaxation
        case touchAndButterflyHug
        case handOverYourHeart
        case mindfulWalking
        case movementDance
        case movementRunning
        case mindfulBodyMovement
        case breathingTechnique
    }

    let id: Int
    /// Localization key present in `Localizable.strings`.
    let titleKey: String
    /// Asset name in `xcassets` / bundle.
    let imageName: String
    let destination: Destination
}

