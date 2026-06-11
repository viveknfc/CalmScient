//
//  NextAppointmentsViewController.swift
//  Calmscient
//
//  Storyboard shell that embeds `NextAppointmentsHostingController` (SwiftUI) on iOS 16+.
//
//  Vivek
//  15 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class NextAppointmentsViewController: ViewController {

    private var appointmentsHost: NextAppointmentsHostingController?

    override func viewDidLoad() {
        super.viewDidLoad()
        installSwiftUIAppointmentsHost()
    }

    private func installSwiftUIAppointmentsHost() {
        view.subviews.forEach { $0.removeFromSuperview() }

        let host = NextAppointmentsHostingController()
        appointmentsHost = host
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
