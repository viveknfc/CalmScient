//
//  HistoryVC.swift
//  Calmscient
//
//  Storyboard shell that embeds `HistoryHostingController` (SwiftUI) on iOS 16+.
//
//  Vivek
//  15 May 2026
//

import SwiftUI
import UIKit

final class HistoryVC: ViewController {

    public weak var selectedScreening: Screening?

    private var historyHost: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 16.0, *) {
            installSwiftUIHistoryHost()
        }
    }

    @available(iOS 16.0, *)
    private func installSwiftUIHistoryHost() {
        view.subviews.forEach { $0.removeFromSuperview() }

        let host = HistoryHostingController()
        if let selectedScreening {
            host.configure(selectedScreening: selectedScreening)
        }
        historyHost = host
        addChild(host)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        host.didMove(toParent: self)
    }
}
