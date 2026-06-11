//
//  QuitSymptomModalViewModel.swift
//  Calmscient
//
//  State and dismissal for ready-to-quit symptom modals.
//
//  Vivek
//  26 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class QuitSymptomModalViewModel: ObservableObject {

    let topic: QuitSymptomTopic
    weak var hostViewController: UIViewController?

    @Published private(set) var content: QuitSymptomModalContentPresentation

    init(topic: QuitSymptomTopic) {
        self.topic = topic
        self.content = QuitSymptomModalPresentation.buildContent(for: topic)
    }

    func reloadLocalizedStrings() {
        content = QuitSymptomModalPresentation.buildContent(for: topic)
    }

    func close() {
        hostViewController?.dismiss(animated: true)
    }

    func attributedHighlightedText(
        fullTextKey: String,
        accentPhraseKeys: [String]
    ) -> AttributedString {
        QuitSymptomModalPresentation.makeHighlightedAttributedText(
            fullTextKey: fullTextKey,
            accentPhraseKeys: accentPhraseKeys
        )
    }

    static func present(topic: QuitSymptomTopic, from presenter: UIViewController) {
        let controller = QuitSymptomModalHostingController(topic: topic)
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        presenter.present(controller, animated: true)
    }

    #if DEBUG
    func applyPreviewState() {
        reloadLocalizedStrings()
    }
    #endif
}
