import Foundation

enum AlcoholAvoidanceReason: String, CaseIterable {
    case interactingMedications = "Taking medications that interact with alcohol"
    case medicalCondition = "Managing a medical condition that can be made worse by drinking"
    case underage = "Under the age of 21, the minimum legal drinking age in the United States"
    case recoveringFromAUD = "Recovering from alcohol use disorder (AUD) or unable to control the amount you drink"
    case pregnantOrMightBe = "Pregnant or might be pregnant"
    case planningToDrive = "Planning to drive a vehicle or operate machinery"
    case requiringSkillActivities = "Participating in activities that require skill, coordination, and alertness"

    static func primaryReasons() -> [AlcoholAvoidanceReason] {
        return [.interactingMedications, .medicalCondition, .underage, .recoveringFromAUD, .pregnantOrMightBe]
    }

    static func additionalReasons() -> [AlcoholAvoidanceReason] {
        return [.planningToDrive, .requiringSkillActivities]
    }
}

func printAlcoholAvoidanceReasons() {
    print("It is safest to avoid alcohol altogether if you are:")
    for (index, reason) in AlcoholAvoidanceReason.primaryReasons().enumerated() {
        print("\(index + 1). \(reason.rawValue)")
    }

    print("\nIn addition, certain individuals, particularly older adults, should avoid alcohol completely if they are:")
    for (index, reason) in AlcoholAvoidanceReason.additionalReasons().enumerated() {
        print("\(index + 1). \(reason.rawValue)")
    }
}
