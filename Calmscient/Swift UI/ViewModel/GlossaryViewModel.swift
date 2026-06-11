//
//  GlossaryViewModel.swift
//  Calmscient
//
//  State and navigation for the glossary list (parity with `GlossyController`).
//
//  Vivek
//  19 May 2026
//

import Foundation
import SwiftUI
import UIKit

@MainActor
final class GlossaryViewModel: ObservableObject {

    private static let termCount = 21

    weak var hostViewController: UIViewController?

    @Published private(set) var terms: [GlossaryTermRowPresentation] = []
    @Published var expandedTermID: Int?

    var navigationChromeTitle: String {
        "Glossary".localized
    }

    func onHostWillAppear() {
        guard terms.isEmpty else { return }
        terms = (1...Self.termCount).map { GlossaryTermRowPresentation(index: $0) }
    }

    func isExpanded(termID: Int) -> Bool {
        expandedTermID == termID
    }

    func toggleTerm(id: Int) {
        if expandedTermID == id {
            expandedTermID = nil
        } else {
            expandedTermID = id
        }
    }

    // MARK: - Navigation

    func openBack() {
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    #if DEBUG
    func applyPreviewState(expandedTermID: Int? = 1) {
        terms = (1...5).map { GlossaryTermRowPresentation(index: $0) }
        self.expandedTermID = expandedTermID
    }
    #endif
}

// MARK: - Navigation

enum GlossaryNavigation {

    static func push(from host: UIViewController, animated: Bool = true) {
        guard let nav = host.navigationController else { return }

        let glossaryHost = GlossaryHostingController()
        nav.pushViewController(glossaryHost, animated: animated)
    }
}
