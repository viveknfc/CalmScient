//
//  BreathingTechniqueType1StepPresentation.swift
//  Calmscient
//
//  Step row model for the 4-7-8 breathing exercise detail screen.
//
//  Vivek
//  20 May 2026
//

import Foundation

struct BreathingTechniqueType1StepPresentation: Identifiable, Equatable {
    let id: Int
    let title: String
    let body: String
}

#if DEBUG
enum BreathingTechniqueType1PreviewData {

    static func sampleSteps() -> [BreathingTechniqueType1StepPresentation] {
        [
            BreathingTechniqueType1StepPresentation(
                id: 0,
                title: "Step 1: Emptying the lungs",
                body: "Begin by completely emptying your lungs of air. Allow yourself a moment to release any tension."
            ),
            BreathingTechniqueType1StepPresentation(
                id: 1,
                title: "Step 2: Inhaling quietly",
                body: "Inhale quietly through your nose, counting to 4 seconds. Fell the breath entering your body, bringing calmness."
            ),
            BreathingTechniqueType1StepPresentation(
                id: 2,
                title: "Step 3: Hold the breath",
                body: "Hold your breath for  a steady count of 7 seconds. Embrace the stillness within, allowing the breath to settle."
            ),
        ]
    }
}
#endif
