//
//  UserMedicationsViewController.swift
//  Calmscient
//
//  Storyboard shell that embeds `UserMedicationsHostingController` (SwiftUI) on iOS 16+.
//
//  Vivek
//  14 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class UserMedicationsViewController: ViewController {

    private var medicationsHost: UserMedicationsHostingController?

    override func viewDidLoad() {
        super.viewDidLoad()
        installSwiftUIMedicationsHost()
    }

    private func installSwiftUIMedicationsHost() {
        view.subviews.forEach { $0.removeFromSuperview() }

        let host = UserMedicationsHostingController()
        medicationsHost = host
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
