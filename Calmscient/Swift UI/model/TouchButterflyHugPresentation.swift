//
//  TouchButterflyHugPresentation.swift
//  Calmscient
//
//  Touch and the butterfly hug static presentation values (parity with legacy UIKit screens).
//
//  Vivek
//  26 May 2026
//

import Foundation

struct TouchButterflyHowToStep: Equatable, Identifiable {
    let id: Int
    let textKey: String
    let imageName: String?
}

enum TouchButterflyHugPresentation {
    static let screenTitleKey = "Touch and the butterfly hug"

    // Intro
    static let introHeroImageName = "touchAndButterfly"
    static let introDescriptionKey =
        "Humans respond powerfully to touch. Gentle, affectionate touch helps calm the nervous system and can trigger the release of oxytocin, the attachment hormone. Interestingly, when it comes to releasing oxytocin, our bodies don’t differentiate between the touch of a loved one or our own touch as we hold ourselves.\nWhen you are feeling upset, ungrounded, agitated or irritable, try giving yourself a hug or a gentle stroke on the cheek and see how it impacts the way you feel."

    static let forwardIconName = "front"

    // How-to
    static let howToTitleKey = "HOW TO DO IT"
    static let howToSteps: [TouchButterflyHowToStep] = [
        TouchButterflyHowToStep(
            id: 0,
            textKey: "Interlock your thumbs to form a butterfly shape",
            imageName: "butterfly 1"
        ),
        TouchButterflyHowToStep(
            id: 1,
            textKey: "Place both hands over your chest, and alternate tapping your middle finger just below your collarbone",
            imageName: "butterfly 1-2"
        ),
        TouchButterflyHowToStep(
            id: 2,
            textKey: "Breathe slowly and deeply (abdominal breathing) while you mentally observe what is going through your mind and body thoughts, images, sounds, odors, feelings, and physical sensation.",
            imageName: nil
        ),
    ]
}

