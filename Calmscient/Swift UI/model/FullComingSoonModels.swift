//
//  FullComingSoonModels.swift
//  Calmscient
//
//  Localization keys and feature rows for the full-version coming soon modal.
//
//  Vivek
//  20 May 2026
//

import Foundation

enum FullComingSoonLocalization {
    static let title = "full_coming_soon_title"
    static let subtitle = "full_coming_soon_subtitle"
    static let featuresQuestion = "full_coming_soon_features_question"
    static let featureTracking = "full_coming_soon_feature_tracking"
    static let featureActionPlan = "full_coming_soon_feature_action_plan"
    static let featureResources = "full_coming_soon_feature_resources"
    static let closeButton = "Close"
}

struct FullComingSoonFeatureItem: Identifiable {
    let id: Int
    let imageNames: [String]
    let descriptionKey: String
}

enum FullComingSoonPresentation {
    static func featureItems() -> [FullComingSoonFeatureItem] {
        [
            FullComingSoonFeatureItem(
                id: 0,
                imageNames: ["BeerWine1", "Cigar"],
                descriptionKey: FullComingSoonLocalization.featureTracking
            ),
            FullComingSoonFeatureItem(
                id: 1,
                imageNames: ["NotePad"],
                descriptionKey: FullComingSoonLocalization.featureActionPlan
            ),
            FullComingSoonFeatureItem(
                id: 2,
                imageNames: ["Badeg"],
                descriptionKey: FullComingSoonLocalization.featureResources
            ),
        ]
    }
}
