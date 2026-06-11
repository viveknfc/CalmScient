//
//  FullComingSoonViewModel.swift
//  Calmscient
//
//  State and dismissal for the full-version coming soon modal (parity with `FullComingSoonVC`).
//
//  Vivek
//  20 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class FullComingSoonViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    let title: String
    let subtitle: String
    let featuresQuestion: String
    let closeButtonTitle: String
    let featureItems: [FullComingSoonFeatureItem]

    init() {
        title = FullComingSoonLocalization.title.localized
        subtitle = FullComingSoonLocalization.subtitle.localized
        featuresQuestion = FullComingSoonLocalization.featuresQuestion.localized
        closeButtonTitle = FullComingSoonLocalization.closeButton.localized
        featureItems = FullComingSoonPresentation.featureItems()
    }

    func localizedDescription(for item: FullComingSoonFeatureItem) -> String {
        item.descriptionKey.localized
    }

    func close() {
        hostViewController?.dismiss(animated: true)
    }

    static func present(from presenter: UIViewController) {
        let controller = FullComingSoonHostingController()
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        presenter.present(controller, animated: true)
    }
}
