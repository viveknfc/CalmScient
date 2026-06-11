//
//  ScreeningListVC.swift
//  Calmscient
//
//  Storyboard shell that embeds `ScreeningListHostingController` (SwiftUI) on iOS 16+.
//
//  Vivek
//  15 May 2026
//

import SwiftUI
import UIKit

final class ScreeningListVC: ViewController {

    var isComingFromParticularVC = false
    var isComingFromParticularVC1 = false

    private var screeningHost: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 16.0, *) {
            installSwiftUIScreeningHost()
        }
    }

    @available(iOS 16.0, *)
    private func installSwiftUIScreeningHost() {
        view.subviews.forEach { $0.removeFromSuperview() }

        let host = ScreeningListHostingController()
        host.configure(
            isComingFromParticularVC: isComingFromParticularVC,
            isComingFromParticularVC1: isComingFromParticularVC1
        )
        screeningHost = host
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
