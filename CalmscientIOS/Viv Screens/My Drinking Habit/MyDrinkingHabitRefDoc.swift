//
//  MyDrinkingHabitRefDoc.swift
//  CalmscientIOS
//
//  Created by NFC User on 26/03/25.
//

import Foundation
import UIKit

struct DrinkingData {
    static let shared: [String: (UIImage, [String])] = [
        "Moderate drinking": (UIImage(named: "check") ?? UIImage(), [
            "Always drink with the moderate drinking standard.",
            "Can effortlessly commit alcohol free plan for week or month.",
            "Can choose to drink or not even though people around you are drinking."
        ]),
        
        "Moderate everyday drinking": (UIImage(named: "check") ?? UIImage(), [
            "Always drink with the moderate drinking standard but struggles to have alcohol-free day.",
            "Drink daily as sleep aids or relaxation.",
            "Expect to have a drink after work or in the evening and get irritated or stressed when you can't have it."
        ]),

        "Social / weekend binge drinking": (UIImage(named: "check") ?? UIImage(), [
            "Casual drinking turns into doing things that you normally wouldn't do or that go against your judgment while you're sober, such as driving under alcohol influence.",
            "Often seek the mood-altering effects (the buzz) or using alcohol as a coping mechanism, sometimes in isolation.",
            "Get defensive when someone tries to limit your consumption or asks you to stop.",
            "Remember? Binge drinking is:\nMen - Up to 5 or more drinks within 2 hrs\nWomen - Up to 4 or more drinks within 2 hrs."
        ]),

        "Problematic drinking": (UIImage(named: "check") ?? UIImage(), [
            "Drinking until drunk.",
            "Going to work drunk or drinking on the job.",
            "Driving while drunk or have driven while drunk.",
            "Getting in trouble with the law or being injured due to drinking.",
            "Doing something under the influence of alcohol that they would not otherwise do.",
            "Having problems at school, with social relationships, or with family members because of drinking.",
            "Using alcohol to decrease anxiety or sadness.",
            "Lying about or trying to hide drinking habits.",
            "Needing more alcohol to feel its effects.",
            "Feeling grouchy, resentful, or unreasonable when not drinking."
        ]),
        
        "Thinking about quitting": (UIImage(named: "check") ?? UIImage(), [
            "You are considering it but haven't made a decision yet.",
            "That's perfectly ok! We will guide you through the benefits of quitting smoking, and then you can decide if you'd like to create a plan for quitting.",
            "Move to Make a plan."
        ]),
        
        "Getting ready to quit": (UIImage(named: "check") ?? UIImage(), [
            "You've decided to quit smoking.",
            "Great decision! We will guide you on how to create a solid plan and help you stay focused on your journey.",
            "Move to Make a plan."
        ]),
        
        "Quitting": (UIImage(named: "check") ?? UIImage(), [
            "You've already started or set a date to quit smoking.",
            "That's great! We will help you create a strategic plan and stay focused on your goal.",
            "Move to Make a plan."
        ]),
        
        "Staying smoke-free": (UIImage(named: "check") ?? UIImage(), [
            "You're focusing on avoiding relapse and keeping up your progress.",
            "That's fantastic. It's important not to let your guard down. We will be here to support you to stay strong.",
            "Move to Make a plan to register the day you started quitting smoking, then you can use Stay focused."
        ])
    ]
}
